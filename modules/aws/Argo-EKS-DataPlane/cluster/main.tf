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
#
# Raw provider resource blocks, not wrapped through wso2/aws-terraform-modules
# - this composite has no dependency on that repo (or any other WSO2 module
# repo) at all. Same tainted-node-pool + subnet-pinned + NAT-per-tier
# isolation pattern as before, just expressed directly.
#
# --------------------------------------------------------------------------------------

locals {
  name = "${var.project}-${var.application}-${var.environment}"
}

resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags                 = merge(var.tags, { Name = "${local.name}-vpc" })
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id
  tags   = merge(var.tags, { Name = "${local.name}-igw" })
}

# --- Public subnets (NAT Gateway placement only, no workloads) ---

resource "aws_subnet" "stage_public" {
  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.stage_public_subnet_cidr_block
  availability_zone       = var.stage_availability_zones[0]
  map_public_ip_on_launch = true
  tags                    = merge(var.tags, { Name = "${local.name}-stage-public" })
}

resource "aws_subnet" "prod_public" {
  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.prod_public_subnet_cidr_block
  availability_zone       = var.prod_availability_zones[0]
  map_public_ip_on_launch = true
  tags                    = merge(var.tags, { Name = "${local.name}-prod-public" })
}

resource "aws_route_table" "stage_public" {
  vpc_id = aws_vpc.this.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }
  tags = merge(var.tags, { Name = "${local.name}-stage-public-rt" })
}

resource "aws_route_table" "prod_public" {
  vpc_id = aws_vpc.this.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }
  tags = merge(var.tags, { Name = "${local.name}-prod-public-rt" })
}

resource "aws_route_table_association" "stage_public" {
  subnet_id      = aws_subnet.stage_public.id
  route_table_id = aws_route_table.stage_public.id
}

resource "aws_route_table_association" "prod_public" {
  subnet_id      = aws_subnet.prod_public.id
  route_table_id = aws_route_table.prod_public.id
}

# --- Per-tier NAT Gateways (own outbound IP each) ---

resource "aws_eip" "stage_nat" {
  domain     = "vpc"
  tags       = merge(var.tags, { Name = "${local.name}-stage-nat-eip" })
  depends_on = [aws_internet_gateway.this]
}

resource "aws_nat_gateway" "stage" {
  allocation_id = aws_eip.stage_nat.id
  subnet_id     = aws_subnet.stage_public.id
  tags          = merge(var.tags, { Name = "${local.name}-stage-nat" })
  depends_on    = [aws_internet_gateway.this]
}

resource "aws_eip" "prod_nat" {
  domain     = "vpc"
  tags       = merge(var.tags, { Name = "${local.name}-prod-nat-eip" })
  depends_on = [aws_internet_gateway.this]
}

resource "aws_nat_gateway" "prod" {
  allocation_id = aws_eip.prod_nat.id
  subnet_id     = aws_subnet.prod_public.id
  tags          = merge(var.tags, { Name = "${local.name}-prod-nat" })
  depends_on    = [aws_internet_gateway.this]
}

# --- Private subnets (EKS nodes live here, tier-isolated egress via each
#     tier's own NAT Gateway) ---

resource "aws_subnet" "stage_private" {
  for_each = { for idx, az in var.stage_availability_zones : az => var.stage_subnet_cidr_blocks[idx] }

  vpc_id            = aws_vpc.this.id
  cidr_block        = each.value
  availability_zone = each.key
  tags              = merge(var.tags, { Name = "${local.name}-stage-${each.key}" })
}

resource "aws_subnet" "prod_private" {
  for_each = { for idx, az in var.prod_availability_zones : az => var.prod_subnet_cidr_blocks[idx] }

  vpc_id            = aws_vpc.this.id
  cidr_block        = each.value
  availability_zone = each.key
  tags              = merge(var.tags, { Name = "${local.name}-prod-${each.key}" })
}

resource "aws_route_table" "stage_private" {
  vpc_id = aws_vpc.this.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.stage.id
  }
  tags = merge(var.tags, { Name = "${local.name}-stage-private-rt" })
}

resource "aws_route_table" "prod_private" {
  vpc_id = aws_vpc.this.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.prod.id
  }
  tags = merge(var.tags, { Name = "${local.name}-prod-private-rt" })
}

resource "aws_route_table_association" "stage_private" {
  for_each       = aws_subnet.stage_private
  subnet_id      = each.value.id
  route_table_id = aws_route_table.stage_private.id
}

resource "aws_route_table_association" "prod_private" {
  for_each       = aws_subnet.prod_private
  subnet_id      = each.value.id
  route_table_id = aws_route_table.prod_private.id
}

# --- Per-tier security groups (extend the EKS-managed cluster SG, don't
#     replace it) ---

resource "aws_security_group" "stage" {
  name_prefix = "${local.name}-stage-"
  description = "Stage-tier data plane nodes"
  vpc_id      = aws_vpc.this.id

  dynamic "ingress" {
    for_each = [for r in var.stage_security_group_rules : r if r.direction == "ingress"]
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
    for_each = [for r in var.stage_security_group_rules : r if r.direction == "egress"]
    content {
      description     = "custom rule"
      from_port       = egress.value.from_port
      to_port         = egress.value.to_port
      protocol        = egress.value.protocol
      cidr_blocks     = egress.value.cidr_blocks
      security_groups = egress.value.security_groups
    }
  }

  tags = merge(var.tags, { Name = "${local.name}-stage-sg" })

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group" "prod" {
  name_prefix = "${local.name}-prod-"
  description = "Prod-tier data plane nodes"
  vpc_id      = aws_vpc.this.id

  dynamic "ingress" {
    for_each = [for r in var.prod_security_group_rules : r if r.direction == "ingress"]
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
    for_each = [for r in var.prod_security_group_rules : r if r.direction == "egress"]
    content {
      description     = "custom rule"
      from_port       = egress.value.from_port
      to_port         = egress.value.to_port
      protocol        = egress.value.protocol
      cidr_blocks     = egress.value.cidr_blocks
      security_groups = egress.value.security_groups
    }
  }

  tags = merge(var.tags, { Name = "${local.name}-prod-sg" })

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

resource "aws_eks_cluster" "this" {
  name     = local.name
  role_arn = aws_iam_role.eks_cluster.arn
  version  = var.kubernetes_version
  bootstrap_self_managed_addons = false

  vpc_config {
    subnet_ids = concat(
      [for s in aws_subnet.stage_private : s.id],
      [for s in aws_subnet.prod_private : s.id],
    )
    endpoint_private_access = true
    endpoint_public_access  = var.endpoint_public_access
    public_access_cidrs     = var.public_access_cidrs
  }

  access_config {
    authentication_mode                         = "API"
    bootstrap_cluster_creator_admin_permissions = true
  }

  tags = var.tags

  depends_on = [aws_iam_role_policy_attachment.eks_cluster_policy]
}

# OIDC provider - needed for per-env IRSA (pipeline pod -> deployment
# target identity), not yet wired up here but the cluster needs this to
# exist before that can be built.
data "tls_certificate" "eks" {
  url = aws_eks_cluster.this.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "eks" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks.certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.this.identity[0].oidc[0].issuer
  tags            = var.tags
}

# --- External Secrets Operator IRSA - real secret names referenced by
#     this data plane's own ExternalSecrets (the IS-deploy pipeline's
#     tier tokens) were copied as-is from an existing Azure Key Vault
#     store and don't follow a path-prefix convention (e.g. "GIT-BOT-PAT",
#     not "argo/data-plane/git-bot-pat") - var.eso_secretsmanager_key_prefix
#     defaults to "*" here for that reason, unlike the control plane's
#     tightly-scoped "argo/control-plane/*". ---

data "aws_iam_policy_document" "eso_assume" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"
    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.eks.url, "https://", "")}:sub"
      values   = ["system:serviceaccount:external-secrets:external-secrets"]
    }
    principals {
      identifiers = [aws_iam_openid_connect_provider.eks.arn]
      type        = "Federated"
    }
  }
}

resource "aws_iam_role" "eso" {
  name               = "${local.name}-eso-role"
  assume_role_policy = data.aws_iam_policy_document.eso_assume.json
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

  cluster_name  = aws_eks_cluster.this.name
  addon_name    = each.value.name
  addon_version = try(each.value.version, null)

  depends_on = [aws_eks_node_group.stage, aws_eks_node_group.prod]
}

# --- Cluster-admin access via native IAM (no unified cross-cloud identity) ---

resource "aws_eks_access_entry" "admin" {
  for_each = toset(var.admin_principal_arns)

  cluster_name  = aws_eks_cluster.this.name
  principal_arn = each.value
  type          = "STANDARD"
}

resource "aws_eks_access_policy_association" "admin" {
  for_each = toset(var.admin_principal_arns)

  cluster_name  = aws_eks_cluster.this.name
  principal_arn = each.value
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"

  access_scope {
    type = "cluster"
  }

  depends_on = [aws_eks_access_entry.admin]
}

# --- Node groups: stage (untainted), prod (tainted) ---

resource "aws_iam_role" "stage_node" {
  name = "${local.name}-stage-node-role"
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

resource "aws_iam_role_policy_attachment" "stage_node_worker" {
  role       = aws_iam_role.stage_node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "stage_node_cni" {
  role       = aws_iam_role.stage_node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "stage_node_ecr" {
  role       = aws_iam_role.stage_node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_launch_template" "stage" {
  name_prefix = "${local.name}-stage-"
  vpc_security_group_ids = [
    aws_eks_cluster.this.vpc_config[0].cluster_security_group_id,
    aws_security_group.stage.id,
  ]

  metadata_options {
    http_tokens = "required"
  }

  tag_specifications {
    resource_type = "instance"
    tags          = merge(var.tags, { Name = "${local.name}-stage-node" })
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_eks_node_group" "stage" {
  cluster_name    = aws_eks_cluster.this.name
  node_group_name = "${local.name}-stage"
  node_role_arn   = aws_iam_role.stage_node.arn
  subnet_ids      = [for s in aws_subnet.stage_private : s.id]
  instance_types  = var.stage_node_instance_types
  capacity_type   = var.stage_node_capacity_type

  launch_template {
    id      = aws_launch_template.stage.id
    version = "$Latest"
  }

  scaling_config {
    min_size     = var.stage_node_min_size
    max_size     = var.stage_node_max_size
    desired_size = var.stage_node_desired_size
  }

  update_config {
    max_unavailable = 1
  }

  labels = { tier = "stage" }

  lifecycle {
    ignore_changes = [scaling_config[0].desired_size]
  }

  tags = var.tags

  depends_on = [
    aws_iam_role_policy_attachment.stage_node_worker,
    aws_iam_role_policy_attachment.stage_node_cni,
    aws_iam_role_policy_attachment.stage_node_ecr,
  ]
}

resource "aws_iam_role" "prod_node" {
  name = "${local.name}-prod-node-role"
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

resource "aws_iam_role_policy_attachment" "prod_node_worker" {
  role       = aws_iam_role.prod_node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "prod_node_cni" {
  role       = aws_iam_role.prod_node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "prod_node_ecr" {
  role       = aws_iam_role.prod_node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_launch_template" "prod" {
  name_prefix = "${local.name}-prod-"
  vpc_security_group_ids = [
    aws_eks_cluster.this.vpc_config[0].cluster_security_group_id,
    aws_security_group.prod.id,
  ]

  metadata_options {
    http_tokens = "required"
  }

  tag_specifications {
    resource_type = "instance"
    tags          = merge(var.tags, { Name = "${local.name}-prod-node" })
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_eks_node_group" "prod" {
  cluster_name    = aws_eks_cluster.this.name
  node_group_name = "${local.name}-prod"
  node_role_arn   = aws_iam_role.prod_node.arn
  subnet_ids      = [for s in aws_subnet.prod_private : s.id]
  instance_types  = var.prod_node_instance_types
  capacity_type   = var.prod_node_capacity_type

  launch_template {
    id      = aws_launch_template.prod.id
    version = "$Latest"
  }

  scaling_config {
    min_size     = var.prod_node_min_size
    max_size     = var.prod_node_max_size
    desired_size = var.prod_node_desired_size
  }

  update_config {
    max_unavailable = 1
  }

  labels = { tier = "prod" }

  taint {
    key    = "env"
    value  = var.prod_node_taint_value
    effect = "NO_SCHEDULE"
  }

  lifecycle {
    ignore_changes = [scaling_config[0].desired_size]
  }

  tags = var.tags

  depends_on = [
    aws_iam_role_policy_attachment.prod_node_worker,
    aws_iam_role_policy_attachment.prod_node_cni,
    aws_iam_role_policy_attachment.prod_node_ecr,
  ]
}

# --- Bastion: native-identity admin access via SSM Session Manager, not a
#     traditional jump box - no inbound rule, no open port, ever. Reaches
#     the SSM service endpoint through the stage subnet's existing NAT
#     Gateway egress, same outbound-only property as Azure Bastion. ---

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

resource "aws_security_group" "bastion" {
  count = var.enable_bastion ? 1 : 0

  name_prefix = "${local.name}-bastion-"
  description = "Bastion instance - zero inbound rules by design, SSM Session Manager only"
  vpc_id      = aws_vpc.this.id

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
  subnet_id              = aws_subnet.stage_private[var.stage_availability_zones[0]].id
  vpc_security_group_ids = [aws_security_group.bastion[0].id]
  iam_instance_profile   = aws_iam_instance_profile.bastion[0].name

  metadata_options {
    http_tokens = "required"
  }

  tags = merge(var.tags, { Name = "${local.name}-bastion" })
}

# --- Per-env IRSA identities for pipeline pods. Trust is scoped to
#     exactly one (namespace, ServiceAccount) pair per entry via the
#     sub condition below - no wildcard, no cross-env reuse possible. ---

data "aws_iam_policy_document" "deploy_identity_assume" {
  for_each = var.deploy_identities

  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.eks.url, "https://", "")}:sub"
      values   = ["system:serviceaccount:${each.value.namespace}:${each.value.service_account_name}"]
    }
    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.eks.url, "https://", "")}:aud"
      values   = ["sts.amazonaws.com"]
    }

    principals {
      identifiers = [aws_iam_openid_connect_provider.eks.arn]
      type        = "Federated"
    }
  }
}

resource "aws_iam_role" "deploy_identity" {
  for_each = var.deploy_identities

  name               = "${local.name}-deploy-${each.key}"
  assume_role_policy = data.aws_iam_policy_document.deploy_identity_assume[each.key].json
  tags               = var.tags
}

resource "aws_iam_role_policy" "deploy_identity" {
  for_each = var.deploy_identities

  name   = "${local.name}-deploy-${each.key}"
  role   = aws_iam_role.deploy_identity[each.key].id
  policy = each.value.policy_json
}
