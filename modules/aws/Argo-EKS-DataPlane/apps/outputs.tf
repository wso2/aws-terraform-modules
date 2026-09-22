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

output "namespace_names" {
  description = "Names of every namespace this module created (var.namespaces plus var.argocd_namespace/var.system_namespace)"
  value       = [for ns in kubernetes_namespace_v1.this : ns.metadata[0].name]
}

output "system_namespace" {
  description = "Namespace the shared argo-server/workflow-controller/argo-events install runs in - same value as var.system_namespace, exposed so a caller doesn't have to keep it in sync separately"
  value       = var.system_namespace
}

output "argocd_namespace" {
  description = "Namespace ArgoCD was installed into - null unless var.install_argocd is true"
  value       = var.install_argocd ? var.argocd_namespace : null
}

output "eso_namespace" {
  description = "Namespace External Secrets Operator was installed into - null unless var.install_external_secrets is true"
  value       = var.install_external_secrets ? var.eso_namespace : null
}

output "gp3_storage_class_name" {
  description = "Name of the ebs.csi.aws.com-backed StorageClass this module creates and marks as the cluster's default (replaces the non-functional in-tree gp2 default)"
  value       = kubernetes_storage_class_v1.gp3.metadata[0].name
}
