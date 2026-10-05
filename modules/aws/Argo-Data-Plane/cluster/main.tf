# -------------------------------------------------------------------------------------
#
# Copyright (c) 2026, WSO2 LLC. (https://www.wso2.com) All Rights Reserved.
#
# WSO2 LLC. licenses this file to you under the Apache License,
# Version 2.0 (the "License"); you may not use this file except
# in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied. See the License for the
# specific language governing permissions and limitations
# under the License.
#
# --------------------------------------------------------------------------------------

# Flow logs are opt-in (enable_vpc_flow_logs) to avoid CloudWatch cost.
# trivy:ignore:AVD-AWS-0178
resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags                 = merge(var.tags, { Name = "${local.name}-vpc" })
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.vpc.id
  tags   = merge(var.tags, { Name = "${local.name}-igw" })
}

# --- Public subnets, one per tier (NAT Gateway placement only, no workloads) ---

resource "aws_subnet" "public" {
  for_each = local.tiers

  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = each.value.public_subnet_cidr_block
  availability_zone       = each.value.availability_zones[0]
  map_public_ip_on_launch = false
  tags                    = merge(var.tags, { Name = "${local.name}-${each.key}-public" })
}

resource "aws_route_table" "public" {
  for_each = local.tiers

  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
  tags = merge(var.tags, { Name = "${local.name}-${each.key}-public-rt" })
}

resource "aws_route_table_association" "public" {
  for_each = local.tiers

  subnet_id      = aws_subnet.public[each.key].id
  route_table_id = aws_route_table.public[each.key].id
}

# --- Per-tier NAT Gateways (own outbound IP each) ---

resource "aws_eip" "nat" {
  for_each = local.tiers

  domain     = "vpc"
  tags       = merge(var.tags, { Name = "${local.name}-${each.key}-nat-eip" })
  depends_on = [aws_internet_gateway.gw]
}

resource "aws_nat_gateway" "nat_gateway" {
  for_each = local.tiers

  allocation_id = aws_eip.nat[each.key].id
  subnet_id     = aws_subnet.public[each.key].id
  tags          = merge(var.tags, { Name = "${local.name}-${each.key}-nat" })
  depends_on    = [aws_internet_gateway.gw]
}

# --- Private subnets (nodes), one per tier and availability zone ---

resource "aws_subnet" "private" {
  for_each = local.private_subnets

  vpc_id            = aws_vpc.vpc.id
  cidr_block        = each.value.cidr_block
  availability_zone = each.value.availability_zone
  tags              = merge(var.tags, { Name = "${local.name}-${each.value.tier}-${each.value.availability_zone}" })
}

resource "aws_route_table" "private" {
  for_each = local.tiers

  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway[each.key].id
  }
  tags = merge(var.tags, { Name = "${local.name}-${each.key}-private-rt" })
}

resource "aws_route_table_association" "private" {
  for_each = local.private_subnets

  subnet_id      = aws_subnet.private[each.key].id
  route_table_id = aws_route_table.private[each.value.tier].id
}

# --- Per-tier security groups ---

resource "aws_security_group" "tier" {
  for_each = local.tiers

  name_prefix = "${local.name}-${each.key}-"
  description = "${title(each.key)}-tier data plane nodes"
  vpc_id      = aws_vpc.vpc.id

  dynamic "ingress" {
    for_each = [for r in each.value.security_group_rules : r if r.direction == "ingress"]
    content {
      description     = "custom rule"
      from_port       = ingress.value.from_port
      to_port         = ingress.value.to_port
      protocol        = ingress.value.protocol
      cidr_blocks     = ingress.value.cidr_blocks
      security_groups = ingress.value.security_groups
    }
  }

  dynamic "egress" {
    for_each = [for r in each.value.security_group_rules : r if r.direction == "egress"]
    content {
      description     = "custom rule"
      from_port       = egress.value.from_port
      to_port         = egress.value.to_port
      protocol        = egress.value.protocol
      cidr_blocks     = egress.value.cidr_blocks
      security_groups = egress.value.security_groups
    }
  }

  tags = merge(var.tags, { Name = "${local.name}-${each.key}-sg" })

  lifecycle {
    create_before_destroy = true
  }
}

# --- EKS cluster ---

resource "aws_iam_role" "eks_cluster" {
  name = "${local.name}-eks-cluster-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "eks.amazonaws.com" }
    }]
  })
  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  role       = aws_iam_role.eks_cluster.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

# Control-plane logging is opt-in (enabled_cluster_log_types) to avoid
# CloudWatch cost. Secrets are envelope-encrypted by EKS with an AWS owned
# key by default on Kubernetes 1.28+, so no encryption_config is set.
# trivy:ignore:AVD-AWS-0038
# trivy:ignore:AVD-AWS-0039
resource "aws_eks_cluster" "eks_cluster" {
  name                          = local.name
  role_arn                      = aws_iam_role.eks_cluster.arn
  version                       = var.kubernetes_version
  bootstrap_self_managed_addons = false

  vpc_config {
    subnet_ids              = [for s in aws_subnet.private : s.id]
    endpoint_private_access = true
    endpoint_public_access  = var.endpoint_public_access
    public_access_cidrs     = var.public_access_cidrs
  }

  # Admin access comes only from admin_principal_arns. Leaving the creator
  # bootstrap on makes EKS add its own access entry for the creating
  # principal, which collides with aws_eks_access_entry.admin when that
  # principal is also listed.
  access_config {
    authentication_mode                         = "API"
    bootstrap_cluster_creator_admin_permissions = false
  }

  enabled_cluster_log_types = var.enabled_cluster_log_types

  tags = var.tags

  depends_on = [aws_iam_role_policy_attachment.eks_cluster_policy]
}

resource "aws_cloudwatch_log_group" "eks_cluster" {
  count = length(var.enabled_cluster_log_types) > 0 ? 1 : 0

  name              = "/aws/eks/${local.name}/cluster"
  retention_in_days = var.log_retention_in_days
  tags              = var.tags

  depends_on = [aws_eks_cluster.eks_cluster]
}

resource "aws_cloudwatch_log_group" "vpc_flow_logs" {
  count = var.enable_vpc_flow_logs ? 1 : 0

  name              = "/aws/vpc/${local.name}-flow-logs"
  retention_in_days = var.log_retention_in_days
  tags              = var.tags
}

data "aws_iam_policy_document" "flow_log_assume" {
  count = var.enable_vpc_flow_logs ? 1 : 0

  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["vpc-flow-logs.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "flow_log" {
  count = var.enable_vpc_flow_logs ? 1 : 0

  name               = "${local.name}-flow-log-role"
  assume_role_policy = data.aws_iam_policy_document.flow_log_assume[0].json
  tags               = var.tags
}

data "aws_iam_policy_document" "flow_log_policy" {
  count = var.enable_vpc_flow_logs ? 1 : 0

  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams",
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "flow_log" {
  count = var.enable_vpc_flow_logs ? 1 : 0

  name   = "${local.name}-flow-log-policy"
  role   = aws_iam_role.flow_log[0].id
  policy = data.aws_iam_policy_document.flow_log_policy[0].json
}

resource "aws_flow_log" "vpc" {
  count = var.enable_vpc_flow_logs ? 1 : 0

  log_destination      = aws_cloudwatch_log_group.vpc_flow_logs[0].arn
  log_destination_type = "cloud-watch-logs"
  iam_role_arn         = aws_iam_role.flow_log[0].arn
  traffic_type         = "ALL"
  vpc_id               = aws_vpc.vpc.id
  tags                 = merge(var.tags, { Name = "${local.name}-flow-log" })
}

resource "aws_s3_bucket" "argo_logs" {
  count = var.enable_artifact_archiving ? 1 : 0

  bucket = "${local.name}-argo-logs"
  tags   = var.tags
}

resource "aws_s3_bucket_public_access_block" "argo_logs" {
  count = var.enable_artifact_archiving ? 1 : 0

  bucket = aws_s3_bucket.argo_logs[0].id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "argo_logs" {
  count = var.enable_artifact_archiving ? 1 : 0

  bucket = aws_s3_bucket.argo_logs[0].id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "argo_logs" {
  count = var.enable_artifact_archiving ? 1 : 0

  bucket = aws_s3_bucket.argo_logs[0].id

  rule {
    id     = "expire-after-retention"
    status = "Enabled"

    filter {}

    expiration {
      days = var.log_retention_in_days
    }
  }
}

# --- IRSA: one trust policy per (namespace, ServiceAccount) in local.irsa_service_accounts ---

resource "aws_iam_openid_connect_provider" "eks" {
  client_id_list = ["sts.amazonaws.com"]
  url            = aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer
  tags           = var.tags
}

data "aws_iam_policy_document" "irsa_assume" {
  for_each = local.irsa_service_accounts

  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${local.oidc_issuer}:sub"
      values   = ["system:serviceaccount:${each.value}"]
    }
    condition {
      test     = "StringEquals"
      variable = "${local.oidc_issuer}:aud"
      values   = ["sts.amazonaws.com"]
    }

    principals {
      identifiers = [aws_iam_openid_connect_provider.eks.arn]
      type        = "Federated"
    }
  }
}

resource "aws_iam_role" "workflow_controller_artifacts" {
  count = var.enable_artifact_archiving ? 1 : 0

  name               = "${local.name}-workflow-artifacts-role"
  assume_role_policy = data.aws_iam_policy_document.irsa_assume["workflow_controller_artifacts"].json
  tags               = var.tags
}

resource "aws_iam_role_policy" "workflow_controller_artifacts" {
  count = var.enable_artifact_archiving ? 1 : 0

  name = "${local.name}-workflow-artifacts-s3"
  role = aws_iam_role.workflow_controller_artifacts[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["s3:PutObject", "s3:GetObject"]
        Resource = "${aws_s3_bucket.argo_logs[0].arn}/*"
      },
      {
        Effect   = "Allow"
        Action   = ["s3:ListBucket"]
        Resource = aws_s3_bucket.argo_logs[0].arn
      }
    ]
  })
}

resource "aws_iam_role" "eso" {
  name               = "${local.name}-eso-role"
  assume_role_policy = data.aws_iam_policy_document.irsa_assume["eso"].json
  tags               = var.tags
}

resource "aws_iam_role_policy" "eso" {
  name = "${local.name}-eso-secretsmanager"
  role = aws_iam_role.eso.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["secretsmanager:GetSecretValue", "secretsmanager:DescribeSecret"]
        Resource = "arn:aws:secretsmanager:*:*:secret:${var.eso_secretsmanager_key_prefix}"
      },
      {
        Effect   = "Allow"
        Action   = ["secretsmanager:ListSecrets"]
        Resource = "*"
      }
    ]
  })
}

resource "aws_eks_addon" "core" {
  for_each = { for a in var.eks_addons : a.name => a }

  cluster_name  = aws_eks_cluster.eks_cluster.name
  addon_name    = each.value.name
  addon_version = try(each.value.version, null)

  # Not the node groups: nodes need vpc-cni to become Ready, so that would deadlock.
  depends_on = [aws_eks_cluster.eks_cluster]
}

# The in-tree gp2 provisioner doesn't work on current Kubernetes.
resource "aws_iam_role" "ebs_csi" {
  name               = "${local.name}-ebs-csi-role"
  assume_role_policy = data.aws_iam_policy_document.irsa_assume["ebs_csi"].json
  tags               = var.tags
}

resource "aws_iam_role_policy_attachment" "ebs_csi" {
  role       = aws_iam_role.ebs_csi.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}

resource "aws_eks_addon" "ebs_csi_driver" {
  cluster_name             = aws_eks_cluster.eks_cluster.name
  addon_name               = "aws-ebs-csi-driver"
  service_account_role_arn = aws_iam_role.ebs_csi.arn

  depends_on = [aws_eks_cluster.eks_cluster, aws_eks_node_group.node]
}

# --- Cluster-admin access ---

resource "aws_eks_access_entry" "admin" {
  for_each = toset(var.admin_principal_arns)

  cluster_name  = aws_eks_cluster.eks_cluster.name
  principal_arn = each.value
  type          = "STANDARD"
}

resource "aws_eks_access_policy_association" "admin" {
  for_each = toset(var.admin_principal_arns)

  cluster_name  = aws_eks_cluster.eks_cluster.name
  principal_arn = each.value
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"

  access_scope {
    type = "cluster"
  }

  depends_on = [aws_eks_access_entry.admin]
}

# --- Node groups, one per tier: stage (untainted), prod (tainted) ---

resource "aws_iam_role" "node" {
  for_each = local.tiers

  name = "${local.name}-${each.key}-node-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })
  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "node" {
  for_each = local.node_policy_attachments

  role       = aws_iam_role.node[each.value.tier].name
  policy_arn = each.value.policy_arn
}

resource "aws_iam_role_policy" "node_extra" {
  for_each = { for tier, t in local.tiers : tier => t if t.node_extra_policy_json != null }

  name   = "${local.name}-${each.key}-node-extra"
  role   = aws_iam_role.node[each.key].id
  policy = each.value.node_extra_policy_json
}

resource "aws_launch_template" "node" {
  for_each = local.tiers

  name_prefix = "${local.name}-${each.key}-"
  vpc_security_group_ids = [
    aws_eks_cluster.eks_cluster.vpc_config[0].cluster_security_group_id,
    aws_security_group.tier[each.key].id,
  ]

  metadata_options {
    http_tokens = "required"
  }

  tag_specifications {
    resource_type = "instance"
    tags          = merge(var.tags, { Name = "${local.name}-${each.key}-node" })
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_eks_node_group" "node" {
  for_each = local.tiers

  cluster_name    = aws_eks_cluster.eks_cluster.name
  node_group_name = "${local.name}-${each.key}"
  node_role_arn   = aws_iam_role.node[each.key].arn
  subnet_ids      = [for k, s in aws_subnet.private : s.id if local.private_subnets[k].tier == each.key]
  instance_types  = each.value.node_instance_types
  capacity_type   = each.value.node_capacity_type

  # A fixed version number: "$Latest" shows a diff on every plan.
  launch_template {
    id      = aws_launch_template.node[each.key].id
    version = aws_launch_template.node[each.key].latest_version
  }

  scaling_config {
    min_size     = each.value.node_min_size
    max_size     = each.value.node_max_size
    desired_size = each.value.node_desired_size
  }

  update_config {
    max_unavailable = 1
  }

  labels = { tier = each.key }

  dynamic "taint" {
    for_each = each.value.node_taint_value != null ? [each.value.node_taint_value] : []
    content {
      key    = "env"
      value  = taint.value
      effect = "NO_SCHEDULE"
    }
  }

  lifecycle {
    ignore_changes = [scaling_config[0].desired_size]
  }

  tags = var.tags

  depends_on = [
    aws_iam_role_policy_attachment.node,
    aws_route_table_association.private,
  ]
}

# --- Bastion (SSM Session Manager only, no inbound rules) ---

data "aws_ami" "bastion" {
  count = var.enable_bastion ? 1 : 0

  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}

resource "aws_iam_role" "bastion" {
  count = var.enable_bastion ? 1 : 0

  name = "${local.name}-bastion-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })
  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "bastion_ssm" {
  count = var.enable_bastion ? 1 : 0

  role       = aws_iam_role.bastion[0].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "bastion" {
  count = var.enable_bastion ? 1 : 0

  name = "${local.name}-bastion-profile"
  role = aws_iam_role.bastion[0].name
  tags = var.tags
}

# Outbound HTTPS only, needed to reach the SSM endpoints. No inbound rules.
# trivy:ignore:AVD-AWS-0104
resource "aws_security_group" "bastion" {
  count = var.enable_bastion ? 1 : 0

  name_prefix = "${local.name}-bastion-"
  description = "Bastion instance - zero inbound rules by design, SSM Session Manager only"
  vpc_id      = aws_vpc.vpc.id

  egress {
    description = "HTTPS to SSM service endpoints"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, { Name = "${local.name}-bastion-sg" })

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_instance" "bastion" {
  count = var.enable_bastion ? 1 : 0

  ami                    = data.aws_ami.bastion[0].id
  instance_type          = var.bastion_instance_type
  subnet_id              = aws_subnet.private["stage/${var.stage_availability_zones[0]}"].id
  vpc_security_group_ids = [aws_security_group.bastion[0].id]
  iam_instance_profile   = aws_iam_instance_profile.bastion[0].name

  root_block_device {
    encrypted = true
  }

  metadata_options {
    http_tokens = "required"
  }

  tags = merge(var.tags, { Name = "${local.name}-bastion" })
}

# --- Per-env IRSA identities for pipeline pods ---

resource "aws_iam_role" "deploy_identity" {
  for_each = var.deploy_identities

  name               = "${local.name}-deploy-${each.key}"
  assume_role_policy = data.aws_iam_policy_document.irsa_assume["deploy/${each.key}"].json
  tags               = var.tags
}

resource "aws_iam_role_policy" "deploy_identity" {
  for_each = var.deploy_identities

  name   = "${local.name}-deploy-${each.key}"
  role   = aws_iam_role.deploy_identity[each.key].id
  policy = each.value.policy_json
}
