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
# Raw kubernetes/helm resources, no dependency on wso2/common-terraform-modules.
#
# --------------------------------------------------------------------------------------

resource "kubernetes_namespace_v1" "this" {
  for_each = toset(concat(var.namespaces, [var.argocd_namespace, var.system_namespace]))

  metadata {
    name = each.value
  }
}

# ONE shared argo-server + workflow-controller per data plane, in
# system_namespace - matches the security review doc's data-plane diagram
# ("system-pool - shared ... argo-server (argo-CLOUD-stage / -prod)") and
# its explicit statement that "the workflow-controller and Argo Events
# controllers see every namespace on their cluster - this is normal
# Kubernetes control-plane behaviour." Tier isolation is real RBAC
# (data-plane-tier-rbac.yaml / data-plane-debug-access-rbac.yaml, applied
# via manifest_files), not separate controller instances per tier.
resource "helm_release" "argo_workflows" {
  name             = "argo-workflows"
  repository       = var.argo_helm_repo
  chart            = "argo-workflows"
  version          = var.argo_workflows_chart_version
  namespace        = var.system_namespace
  create_namespace = false
  values           = var.argo_workflows_values

  depends_on = [kubernetes_namespace_v1.this]
}

resource "helm_release" "argo_events" {
  name             = "argo-events"
  repository       = var.argo_helm_repo
  chart            = "argo-events"
  version          = var.argo_events_chart_version
  namespace        = var.system_namespace
  create_namespace = false
  values           = var.argo_events_values

  depends_on = [kubernetes_namespace_v1.this]
}

resource "helm_release" "argocd" {
  count = var.install_argocd ? 1 : 0

  name             = "argocd"
  repository       = var.argocd_helm_repo
  chart            = "argo-cd"
  version          = var.argocd_chart_version
  namespace        = var.argocd_namespace
  create_namespace = false
  values           = var.argocd_values

  depends_on = [kubernetes_namespace_v1.this]
}

# --- External Secrets Operator - syncs this data plane's own tier tokens
#     (currently referenced by the real ExternalSecret files as bare,
#     unprefixed key names, copied from an existing Azure Key Vault store)
#     from AWS Secrets Manager. Same IRSA-annotated-controller pattern as
#     the control plane's install. ---

resource "kubernetes_namespace_v1" "external_secrets" {
  count = var.install_external_secrets ? 1 : 0

  metadata {
    name = var.eso_namespace
  }
}

resource "helm_release" "external_secrets" {
  count = var.install_external_secrets ? 1 : 0

  name             = "external-secrets"
  repository       = var.eso_helm_repo
  chart            = "external-secrets"
  version          = var.eso_chart_version
  namespace        = var.eso_namespace
  create_namespace = false

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = var.eso_role_arn
  }

  depends_on = [kubernetes_namespace_v1.external_secrets]
}

# Several real pipeline manifests are multi-document YAML (Deployment +
# Service + IngressRoute in one file, multiple RBAC objects, etc.) - split
# on a bare "---" line first. This is a real fix, not a design choice:
# applying these files through the previous wso2 kubernetes/Manifest module
# had the exact same single-document limitation.
#
# kubectl_manifest (not kubernetes_manifest) - same silent-client-
# construction-failure bug control-plane's main.tf documents
# ("kubernetes_manifest's silent token-drop bug with static tokens"):
# kubernetes_manifest builds its own REST client independently of the rest
# of the provider, and that path doesn't reliably work with exec-based auth
# (aws eks get-token here) - confirmed failing on Azure's equivalent module
# with the identical "cannot create REST client: no client config" error on
# every instance, regardless of parallelism. kubectl_manifest takes raw
# YAML text directly, so no yamldecode() round-trip is needed either.
locals {
  manifest_documents = flatten([
    for idx, m in var.manifest_files : [
      for doc_idx, doc in [
        for chunk in split("\n---\n", "\n${m.content != null ? m.content : templatefile(m.location, m.template_map)}") : chunk
        if trimspace(chunk) != ""
        ] : {
        key  = "${idx}-${doc_idx}"
        body = doc
      }
    ]
  ])
}

resource "kubectl_manifest" "this" {
  for_each = { for d in local.manifest_documents : d.key => d.body }

  yaml_body = each.value

  depends_on = [helm_release.argo_workflows, helm_release.argo_events, helm_release.argocd]
}

# CRD-backed manifests (ESO's ClusterSecretStore/ExternalSecret) applied in
# the same run that installs their CRDs - see the control-plane apps
# module's identical mechanism for why kubectl_manifest, not
# kubernetes_manifest, is required here.
locals {
  kubectl_manifest_documents = flatten([
    for idx, m in var.kubectl_manifest_files : [
      for doc_idx, doc in [
        for chunk in split("\n---\n", "\n${m.content != null ? m.content : templatefile(m.location, m.template_map)}") : chunk
        if trimspace(chunk) != ""
        ] : {
        key  = "${idx}-${doc_idx}"
        body = doc
      }
    ]
  ])
}

resource "kubectl_manifest" "extra" {
  for_each = { for d in local.kubectl_manifest_documents : d.key => d.body }

  yaml_body = each.value

  depends_on = [helm_release.external_secrets, helm_release.argo_workflows, helm_release.argo_events, helm_release.argocd]
}
