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
# Raw kubernetes/helm resources, no dependency on wso2/common-terraform-modules.
#
# --------------------------------------------------------------------------------------

resource "kubernetes_namespace_v1" "this" {
  for_each = toset(concat(var.namespaces, [var.argocd_namespace, var.system_namespace]))

  metadata {
    name = each.value
  }
}

# gp3 StorageClass backed by ebs.csi.aws.com - the default gp2 in-tree
# provisioner doesn't function on modern k8s.
resource "kubernetes_storage_class_v1" "gp3" {
  metadata {
    name = "gp3"
    annotations = {
      "storageclass.kubernetes.io/is-default-class" = "true"
    }
  }

  storage_provisioner    = "ebs.csi.aws.com"
  reclaim_policy         = "Delete"
  volume_binding_mode    = "WaitForFirstConsumer"
  allow_volume_expansion = true

  parameters = {
    type = "gp3"
  }
}

# One shared argo-server + workflow-controller per data plane, in
# system_namespace. Tier isolation is RBAC (applied via manifest_files),
# not separate controller instances per tier.
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

# External Secrets Operator - syncs this data plane's secrets from AWS
# Secrets Manager, same IRSA-annotated-controller pattern as the control
# plane's install.

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

# Split multi-document YAML manifests on a bare "---" line first, then
# apply each via kubectl_manifest (not kubernetes_manifest) - its REST
# client doesn't reliably work with exec-based auth (aws eks get-token).
locals {
  manifest_documents = flatten([
    for idx, m in var.manifest_files : [
      for doc_idx, doc in [
        for chunk in split("\n---\n", "\n${m.content != null ? m.content : templatefile(m.location, m.template_map)}") : chunk
        if trimspace(chunk) != ""
        ] : {
        key       = "${idx}-${doc_idx}"
        body      = doc
        namespace = m.namespace
      }
    ]
  ])
}

resource "kubectl_manifest" "this" {
  for_each = { for d in local.manifest_documents : d.key => d }

  yaml_body          = each.value.body
  override_namespace = each.value.namespace

  # false, not the Deployment/DaemonSet/StatefulSet default of true -
  # some manifests here depend on state only created once this whole
  # module finishes applying, which would otherwise deadlock.
  wait_for_rollout = false

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
        key       = "${idx}-${doc_idx}"
        body      = doc
        namespace = m.namespace
      }
    ]
  ])
}

resource "kubectl_manifest" "extra" {
  for_each = { for d in local.kubectl_manifest_documents : d.key => d }

  yaml_body          = each.value.body
  override_namespace = each.value.namespace

  # See kubectl_manifest.this's identical comment on wait_for_rollout.
  wait_for_rollout = false

  depends_on = [helm_release.external_secrets, helm_release.argo_workflows, helm_release.argo_events, helm_release.argocd]
}

# Writes each entry's already-rendered content to local disk under this
# module's own directory - for inspecting what a manifest_files/
# kubectl_manifest_files entry actually resolved to, not applied to the
# cluster itself.
resource "local_file" "rendered_manifest" {
  for_each = var.rendered_manifest_files

  filename = "${path.module}/.rendered/${each.value.file_name}"
  content  = each.value.content
}
