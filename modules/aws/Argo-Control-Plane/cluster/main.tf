# -------------------------------------------------------------------------------------
#
# Copyright (c) 2026, WSO2 LLC. (http://www.wso2.com). All Rights Reserved.
#
# This software is the property of WSO2 LLC. and its suppliers, if any.
# Dissemination of any information or reproduction of any material contained
# herein in any form is strictly forbidden, unless permitted by WSO2 expressly.
# You may not alter or remove any copyright or other notice from copies of this content.
#
# --------------------------------------------------------------------------------------

# Ignore: AVD-AWS-0178 (https://avd.aquasec.com/misconfig/aws/ec2/avd-aws-0178)
# Reason: For more granular control Flow logs are enabled at the subnet level via a separate module at the subnet level (Refer VPC-Flow-Log Module), instead of the VPC level.
# trivy:ignore:AVD-AWS-0178
resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags                 = local.vpc_tags
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.vpc.id
  tags   = local.igw_tags
}

resource "aws_subnet" "public" {
  for_each = { for idx, az in var.availability_zones : az => idx }

  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.public_subnet_cidr_blocks[each.value]
  availability_zone       = each.key
  map_public_ip_on_launch = true
  tags                    = merge(var.tags, { Name = join("-", [local.name_prefix, "public", each.key]) })
}

resource "aws_route_table" "public" {
  for_each = { for idx, az in var.availability_zones : az => idx }

  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
  tags = merge(var.tags, { Name = join("-", [local.name_prefix, "public", each.key, "rt"]) })
}

resource "aws_route_table_association" "public" {
  for_each = aws_subnet.public

  subnet_id      = each.value.id
  route_table_id = aws_route_table.public[each.key].id
}

resource "aws_eip" "nat" {
  for_each = { for idx, az in var.availability_zones : az => idx }

  domain     = "vpc"
  tags       = merge(var.tags, { Name = join("-", [local.name_prefix, each.key, "nat-eip"]) })
  depends_on = [aws_internet_gateway.gw]
}

resource "aws_nat_gateway" "nat_gateway" {
  for_each = { for idx, az in var.availability_zones : az => idx }

  allocation_id = aws_eip.nat[each.key].id
  subnet_id     = aws_subnet.public[each.key].id
  tags          = merge(var.tags, { Name = join("-", [local.name_prefix, each.key, "nat"]) })
  depends_on    = [aws_internet_gateway.gw]
}

resource "aws_subnet" "private" {
  for_each = { for idx, az in var.availability_zones : az => idx }

  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.private_subnet_cidr_blocks[each.value]
  availability_zone = each.key
  tags              = merge(var.tags, { Name = join("-", [local.name_prefix, "private", each.key]) })
}

resource "aws_route_table" "private" {
  for_each = { for idx, az in var.availability_zones : az => idx }

  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway[each.key].id
  }
  tags = merge(var.tags, { Name = join("-", [local.name_prefix, "private", each.key, "rt"]) })
}

resource "aws_route_table_association" "private" {
  for_each = aws_subnet.private

  subnet_id      = each.value.id
  route_table_id = aws_route_table.private[each.key].id
}

resource "aws_security_group" "security_group" {
  name_prefix = "${local.name_prefix}-"
  description = "Control plane nodes"
  vpc_id      = aws_vpc.vpc.id

  dynamic "ingress" {
    for_each = [for r in var.security_group_rules : r if r.direction == "ingress"]
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
    for_each = [for r in var.security_group_rules : r if r.direction == "egress"]
    content {
      description     = "custom rule"
      from_port       = egress.value.from_port
      to_port         = egress.value.to_port
      protocol        = egress.value.protocol
      cidr_blocks     = egress.value.cidr_blocks
      security_groups = egress.value.security_groups
    }
  }

  tags = local.cluster_sg_tags

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_iam_role" "eks_cluster" {
  name = local.eks_cluster_role_name
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

# Ignore: AVD-AWS-0038 (https://avd.aquasec.com/misconfig/aws/eks/avd-aws-0038/)
# Reason: Requirement to enable logs for EKS cluster will vary based on cluster purpose and requirements
# Therefore has not been enforced as a requirement
# Ignore: AVD-AWS-0039 (https://avd.aquasec.com/misconfig/aws/eks/avd-aws-0039/)
# Reason: Encrypting Secrets will depend on Cluster usage (usage of CSI driver etc) as such
# This has been configured as an optional parameter
# trivy:ignore:AVD-AWS-0038
# trivy:ignore:AVD-AWS-0039
resource "aws_eks_cluster" "eks_cluster" {
  name     = local.eks_cluster_name
  role_arn = aws_iam_role.eks_cluster.arn
  version  = var.kubernetes_version

  bootstrap_self_managed_addons = false

  vpc_config {
    subnet_ids              = [for az in var.availability_zones : aws_subnet.private[az].id]
    endpoint_private_access = true
    endpoint_public_access  = var.endpoint_public_access
    public_access_cidrs     = var.public_access_cidrs
  }

  access_config {
    authentication_mode                         = "API"
    bootstrap_cluster_creator_admin_permissions = true
  }

  dynamic "encryption_config" {
    for_each = var.secret_encryption_cmk != null ? [1] : []
    content {
      provider {
        key_arn = var.secret_encryption_cmk
      }
      resources = ["secrets"]
    }
  }

  enabled_cluster_log_types = var.enabled_cluster_log_types

  tags = var.tags

  depends_on = [aws_iam_role_policy_attachment.eks_cluster_policy]
}

data "tls_certificate" "eks" {
  url = aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "eks" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks.certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer
  tags            = var.tags
}

data "aws_iam_policy_document" "ebs_csi_assume" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"
    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.eks.url, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:ebs-csi-controller-sa"]
    }
    principals {
      identifiers = [aws_iam_openid_connect_provider.eks.arn]
      type        = "Federated"
    }
  }
}

resource "aws_iam_role" "ebs_csi" {
  name               = local.ebs_csi_role_name
  assume_role_policy = data.aws_iam_policy_document.ebs_csi_assume.json
  tags               = var.tags
}

resource "aws_iam_role_policy_attachment" "ebs_csi" {
  role       = aws_iam_role.ebs_csi.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}

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
  name               = local.eso_role_name
  assume_role_policy = data.aws_iam_policy_document.eso_assume.json
  tags               = var.tags
}

resource "aws_iam_role_policy" "eso" {
  name = local.eso_policy_name
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

  depends_on = [aws_eks_cluster.eks_cluster, aws_eks_node_group.eks_node_group]
}

resource "aws_eks_addon" "ebs_csi_driver" {
  cluster_name             = aws_eks_cluster.eks_cluster.name
  addon_name               = "aws-ebs-csi-driver"
  service_account_role_arn = aws_iam_role.ebs_csi.arn

  depends_on = [aws_eks_cluster.eks_cluster, aws_eks_node_group.eks_node_group]
}

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

resource "aws_iam_role" "node" {
  name = local.node_role_name
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

resource "aws_iam_role_policy_attachment" "node_worker" {
  role       = aws_iam_role.node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "node_cni" {
  role       = aws_iam_role.node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "node_ecr" {
  role       = aws_iam_role.node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_launch_template" "launch_template" {
  name_prefix = "${local.launch_template_name}-"
  vpc_security_group_ids = [
    aws_eks_cluster.eks_cluster.vpc_config[0].cluster_security_group_id,
    aws_security_group.security_group.id,
  ]

  metadata_options {
    http_tokens = "required"
  }

  tag_specifications {
    resource_type = "instance"
    tags          = local.launch_template_tags
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_eks_node_group" "eks_node_group" {
  cluster_name    = aws_eks_cluster.eks_cluster.name
  node_group_name = local.node_group_name
  node_role_arn   = aws_iam_role.node.arn
  subnet_ids      = [for az in var.availability_zones : aws_subnet.private[az].id]
  instance_types  = var.node_instance_types
  capacity_type   = var.node_capacity_type

  launch_template {
    id      = aws_launch_template.launch_template.id
    version = "$Latest"
  }

  scaling_config {
    min_size     = var.node_min_size
    max_size     = var.node_max_size
    desired_size = var.node_desired_size
  }

  update_config {
    max_unavailable = 1
  }

  lifecycle {
    ignore_changes = [scaling_config[0].desired_size]
  }

  tags = var.tags

  depends_on = [
    aws_iam_role_policy_attachment.node_worker,
    aws_iam_role_policy_attachment.node_cni,
    aws_iam_role_policy_attachment.node_ecr,
  ]
}

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

  name = local.bastion_role_name
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

  name = local.bastion_profile_name
  role = aws_iam_role.bastion[0].name
  tags = var.tags
}

resource "aws_security_group" "bastion" {
  count = var.enable_bastion ? 1 : 0

  name_prefix = "${local.bastion_sg_name}-"
  description = "Bastion instance - zero inbound rules by design, SSM Session Manager only"
  vpc_id      = aws_vpc.vpc.id

  egress {
    description = "HTTPS to SSM service endpoints"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = local.bastion_sg_tags

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_instance" "bastion" {
  count = var.enable_bastion ? 1 : 0

  ami                    = data.aws_ami.bastion[0].id
  instance_type          = var.bastion_instance_type
  subnet_id              = aws_subnet.private[var.availability_zones[0]].id
  vpc_security_group_ids = [aws_security_group.bastion[0].id]
  iam_instance_profile   = aws_iam_instance_profile.bastion[0].name

  root_block_device {
    encrypted = true
  }

  metadata_options {
    http_tokens = "required"
  }

  tags = local.bastion_tags
}
