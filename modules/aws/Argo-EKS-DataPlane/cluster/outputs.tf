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
  value = aws_eks_cluster.this.name
}

output "eks_cluster_arn" {
  value = aws_eks_cluster.this.arn
}

output "eks_cluster_endpoint" {
  value = aws_eks_cluster.this.endpoint
}

output "eks_base64_encoded_ca_cert" {
  value = aws_eks_cluster.this.certificate_authority[0].data
}

output "oidc_provider_arn" {
  value = aws_iam_openid_connect_provider.eks.arn
}

output "oidc_provider_url" {
  value = aws_iam_openid_connect_provider.eks.url
}

output "vpc_id" {
  value = aws_vpc.this.id
}

output "stage_subnet_ids" {
  value = [for s in aws_subnet.stage_private : s.id]
}

output "prod_subnet_ids" {
  value = [for s in aws_subnet.prod_private : s.id]
}

output "stage_nat_gateway_public_ip" {
  value = aws_eip.stage_nat.public_ip
}

output "prod_nat_gateway_public_ip" {
  value = aws_eip.prod_nat.public_ip
}

output "bastion_instance_id" {
  description = "aws ssm start-session --target <this> to reach the bastion"
  value       = var.enable_bastion ? aws_instance.bastion[0].id : null
}

output "deploy_identity_role_arns" {
  description = "Role ARN per deploy_identities entry - annotate the matching ServiceAccount with eks.amazonaws.com/role-arn: <this value>"
  value       = { for k, r in aws_iam_role.deploy_identity : k => r.arn }
}

output "eso_role_arn" {
  description = "IRSA role ARN for External Secrets Operator's own controller ServiceAccount (external-secrets/external-secrets)"
  value       = aws_iam_role.eso.arn
}

output "workflow_controller_artifacts_role_arn" {
  description = "IRSA role ARN for the workflow-controller ServiceAccount to write to artifact_bucket_name - null unless enable_artifact_archiving is true"
  value       = var.enable_artifact_archiving ? aws_iam_role.workflow_controller_artifacts[0].arn : null
}

output "artifact_bucket_name" {
  description = "S3 bucket Argo Workflows should archive logs/artifacts to - null unless enable_artifact_archiving is true"
  value       = var.enable_artifact_archiving ? aws_s3_bucket.argo_logs[0].id : null
}
