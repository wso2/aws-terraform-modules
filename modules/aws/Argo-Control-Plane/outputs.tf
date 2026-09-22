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
# A curated merge of cluster/outputs.tf and apps/outputs.tf - only what a
# consumer of this composite module (e.g. a data-plane environment wiring
# in this control plane's NATS/tunnel material, or an operator reaching the
# bastion) would actually reference downstream, not every internal output
# either submodule exposes.
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

output "eso_role_arn" {
  description = "IRSA role ARN for External Secrets Operator's own controller ServiceAccount - already wired into module.apps by this composite module, exposed here too since a caller's own argo_workflows_values/other Helm overrides may need it directly"
  value       = module.cluster.eso_role_arn
}

output "workflow_controller_artifacts_role_arn" {
  value = module.cluster.workflow_controller_artifacts_role_arn
}

output "artifact_bucket_name" {
  value = module.cluster.artifact_bucket_name
}

# --- From module.apps ---

output "nats_client_cert_pems" {
  description = "Per data-plane-identity NATS client cert PEM - copy out-of-band into that data plane's own terraform.tfvars, same pattern as tunnel_client_private_keys"
  value       = module.apps.nats_client_cert_pems
  sensitive   = true
}

output "nats_client_key_pems" {
  value     = module.apps.nats_client_key_pems
  sensitive = true
}

output "nats_client_ca_pems" {
  value     = module.apps.nats_client_ca_pems
  sensitive = true
}

output "tunnel_client_private_keys" {
  description = "OpenSSH-formatted private key per identity in tunnel_client_identities - copy into that data plane's own terraform.tfvars tunnel_client_private_key."
  value       = module.apps.tunnel_client_private_keys
  sensitive   = true
}
