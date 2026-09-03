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

output "eks_cluster_name" {
  value = aws_eks_cluster.eks_cluster.name
}

output "eks_cluster_arn" {
  value = aws_eks_cluster.eks_cluster.arn
}

output "eks_cluster_endpoint" {
  value = aws_eks_cluster.eks_cluster.endpoint
}

output "eks_base64_encoded_ca_cert" {
  value = aws_eks_cluster.eks_cluster.certificate_authority[0].data
}

output "oidc_provider_arn" {
  value = aws_iam_openid_connect_provider.eks.arn
}

output "oidc_provider_url" {
  value = aws_iam_openid_connect_provider.eks.url
}

output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "private_subnet_ids" {
  value = [for az in var.availability_zones : aws_subnet.private[az].id]
}

output "nat_gateway_public_ips" {
  value = { for az in var.availability_zones : az => aws_eip.nat[az].public_ip }
}

output "bastion_instance_id" {
  description = "aws ssm start-session --target <this> to reach the bastion"
  value       = var.enable_bastion ? aws_instance.bastion[0].id : null
}

output "eso_role_arn" {
  description = "IRSA role ARN for External Secrets Operator's own controller ServiceAccount (external-secrets/external-secrets)"
  value       = aws_iam_role.eso.arn
}

output "workflow_controller_artifacts_role_arn" {
  description = "IRSA role ARN for the workflow-controller ServiceAccount to write to s3_artifact_bucket_arn - null when that variable wasn't set"
  value       = var.s3_artifact_bucket_arn != null ? aws_iam_role.workflow_controller_artifacts[0].arn : null
}
