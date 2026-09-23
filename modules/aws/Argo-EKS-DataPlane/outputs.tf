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
#
# Outputs a caller composing through this module actually needs
# downstream, not every internal cluster/apps output.
#
# --------------------------------------------------------------------------------------

# --- From module.cluster ---

output "eks_cluster_name" {
  value = module.cluster.eks_cluster_name
}

output "eks_cluster_endpoint" {
  value = module.cluster.eks_cluster_endpoint
}

output "eks_base64_encoded_ca_cert" {
  value     = module.cluster.eks_base64_encoded_ca_cert
  sensitive = true
}

output "vpc_id" {
  value = module.cluster.vpc_id
}

output "bastion_instance_id" {
  description = "aws ssm start-session --target <this> to reach the bastion"
  value       = module.cluster.bastion_instance_id
}

output "deploy_identity_role_arns" {
  description = "Role ARN per deploy_identities entry - annotate the matching ServiceAccount with eks.amazonaws.com/role-arn: <this value>"
  value       = module.cluster.deploy_identity_role_arns
}

output "eso_role_arn" {
  description = "IRSA role ARN for External Secrets Operator's controller ServiceAccount - already wired into module.apps; exposed here too for a caller's own Helm overrides."
  value       = module.cluster.eso_role_arn
}

output "workflow_controller_artifacts_role_arn" {
  value = module.cluster.workflow_controller_artifacts_role_arn
}

output "artifact_bucket_name" {
  value = module.cluster.artifact_bucket_name
}

# --- From module.apps ---

output "namespace_names" {
  value = module.apps.namespace_names
}

output "system_namespace" {
  value = module.apps.system_namespace
}

output "argocd_namespace" {
  value = module.apps.argocd_namespace
}

output "eso_namespace" {
  value = module.apps.eso_namespace
}

output "gp3_storage_class_name" {
  value = module.apps.gp3_storage_class_name
}
