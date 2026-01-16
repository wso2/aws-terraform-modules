# -------------------------------------------------------------------------------------
#
# Copyright (c) 2023, WSO2 LLC. (http://www.wso2.com). All Rights Reserved.
#
# This software is the property of WSO2 LLC. and its suppliers, if any.
# Dissemination of any information or reproduction of any material contained
# herein in any form is strictly forbidden, unless permitted by WSO2 expressly.
# You may not alter or remove any copyright or other notice from copies of this content.
#
# --------------------------------------------------------------------------------------

# trivy:ignore:AVD-AWS-0038 Logging requirements vary based on cluster purpose
# trivy:ignore:AVD-AWS-0039 Secret encryption is configurable via parameter
resource "aws_eks_cluster" "eks_cluster" {
  name     = join("-", [var.eks_cluster_abbreviation, var.eks_cluster_name])
  role_arn = aws_iam_role.iam_role[0].arn

  version = var.kubernetes_version

  vpc_config {
    endpoint_private_access = var.endpoint_private_access
    endpoint_public_access  = var.endpoint_public_access
    public_access_cidrs     = var.public_access_cidrs
    subnet_ids              = length(var.cluster_subnet_ids) == 0 ? aws_subnet.eks_subnet[*].id : var.cluster_subnet_ids
  }

  access_config {
    authentication_mode                         = var.authentication_mode
    bootstrap_cluster_creator_admin_permissions = var.bootstrap_cluster_creator_admin_permissions
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

  kubernetes_network_config {
    service_ipv4_cidr = var.service_ipv4_cidr
  }

  enabled_cluster_log_types = var.enabled_cluster_log_types

  # Ensure that IAM Role permissions are created before and deleted after EKS Cluster handling.
  # Otherwise, EKS will not be able to properly delete EKS managed EC2 infrastructure such as Security Groups.
  depends_on = [
    aws_iam_role_policy_attachment.amazon_eks_cluster_policy,
    aws_iam_role_policy_attachment.amazon_eks_pc_resource_controller,
  ]
  tags = var.tags
}
