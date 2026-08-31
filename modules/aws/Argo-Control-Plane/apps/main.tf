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
  metadata {
    name = var.namespace
  }
}

# --- cert-manager + private client-CA for NATS mTLS. Real design change,
#     not a one-time fix: cert-manager renews before expiry on its own,
#     unlike Terraform's tls provider (common-terraform-modules' tls
#     module), which only generates once at apply time. ---

resource "kubernetes_namespace_v1" "cert_manager" {
  count = var.install_cert_manager ? 1 : 0

  metadata {
    name = var.cert_manager_namespace
  }
}

resource "helm_release" "cert_manager" {
  count = var.install_cert_manager ? 1 : 0

  name             = "cert-manager"
  repository       = var.cert_manager_helm_repo
  chart            = "cert-manager"
  version          = var.cert_manager_chart_version
  namespace        = var.cert_manager_namespace
  create_namespace = false

  set {
    name  = "crds.enabled"
    value = "true"
  }

  depends_on = [kubernetes_namespace_v1.cert_manager]
}

# Standard cert-manager two-step bootstrap: self-signed Issuer → CA Certificate → ClusterIssuer backed by that CA.
resource "kubectl_manifest" "selfsigned_issuer" {
  count = var.install_cert_manager ? 1 : 0

  yaml_body = yamlencode({
    apiVersion = "cert-manager.io/v1"
    kind       = "Issuer"
    metadata = {
      name      = "selfsigned-bootstrap"
      namespace = var.cert_manager_namespace
    }
    spec = { selfSigned = {} }
  })

  depends_on = [helm_release.cert_manager]
}

resource "kubectl_manifest" "nats_ca_certificate" {
  count = var.install_cert_manager ? 1 : 0

  yaml_body = yamlencode({
    apiVersion = "cert-manager.io/v1"
    kind       = "Certificate"
    metadata = {
      name      = "nats-client-ca"
      namespace = var.cert_manager_namespace
    }
    spec = {
      isCA       = true
      commonName = "nats-client-ca"
      secretName = "nats-client-ca-secret"
      duration   = "8760h" # 1 year
      privateKey = { algorithm = "ECDSA", size = 256 }
      issuerRef = {
        name = "selfsigned-bootstrap"
        kind = "Issuer"
      }
    }
  })

  depends_on = [kubectl_manifest.selfsigned_issuer]
}

resource "kubectl_manifest" "nats_ca_issuer" {
  count = var.install_cert_manager ? 1 : 0

  yaml_body = yamlencode({
    apiVersion = "cert-manager.io/v1"
    kind       = "ClusterIssuer"
    metadata = {
      name = "nats-client-ca-issuer"
    }
    spec = {
      ca = { secretName = "nats-client-ca-secret" }
    }
  })

  depends_on = [kubectl_manifest.nats_ca_certificate]
}

# The control plane's own NATS server certificate - the "wildcard"
# identity the security review doc describes.
resource "kubectl_manifest" "nats_server_certificate" {
  count = var.install_cert_manager ? 1 : 0

  yaml_body = yamlencode({
    apiVersion = "cert-manager.io/v1"
    kind       = "Certificate"
    metadata = {
      name      = "nats-server-cert"
      namespace = var.namespace
    }
    spec = {
      commonName  = "nats-server"
      secretName  = "nats-server-cert"
      duration    = "2160h" # 90 days - rotated automatically well before expiry
      renewBefore = "360h"  # 15 days
      privateKey  = { algorithm = "ECDSA", size = 256 }
      usages      = ["server auth", "client auth"]
      dnsNames    = ["nats.${var.namespace}.svc.cluster.local", "nats"]
      issuerRef = {
        name = "nats-client-ca-issuer"
        kind = "ClusterIssuer"
      }
    }
  })

  depends_on = [kubectl_manifest.nats_ca_issuer]
}

# Per-data-plane client identities (one cert per cloud x env, e.g. "aws-stage").
resource "kubectl_manifest" "nats_client_certificate" {
  for_each = var.install_cert_manager ? toset(var.nats_client_identities) : []

  yaml_body = yamlencode({
    apiVersion = "cert-manager.io/v1"
    kind       = "Certificate"
    metadata = {
      name      = "nats-client-${each.value}"
      namespace = var.namespace
    }
    spec = {
      commonName  = each.value
      secretName  = "nats-client-${each.value}-secret"
      duration    = "2160h"
      renewBefore = "360h"
      privateKey  = { algorithm = "ECDSA", size = 256 }
      usages      = ["client auth"]
      issuerRef = {
        name = "nats-client-ca-issuer"
        kind = "ClusterIssuer"
      }
    }
  })

  depends_on = [kubectl_manifest.nats_ca_issuer]
}

# Read back each issued client cert's Secret so the PEM content can be output.
data "kubernetes_secret_v1" "nats_client_certificate" {
  for_each = var.install_cert_manager ? toset(var.nats_client_identities) : []

  metadata {
    name      = "nats-client-${each.value}-secret"
    namespace = var.namespace
  }

  depends_on = [kubectl_manifest.nats_client_certificate]
}

# gp3 StorageClass backed by the EBS CSI driver - required for NATS JetStream PVCs.
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

resource "helm_release" "nats" {
  name             = "nats"
  repository       = var.nats_helm_repo
  chart            = "nats"
  version          = var.nats_chart_version
  namespace        = var.namespace
  create_namespace = false
  values           = var.nats_values

  depends_on = [kubernetes_namespace_v1.this, kubectl_manifest.nats_server_certificate, kubernetes_storage_class_v1.gp3]
}

resource "helm_release" "argo_workflows" {
  name             = "argo-workflows"
  repository       = var.argo_helm_repo
  chart            = "argo-workflows"
  version          = var.argo_workflows_chart_version
  namespace        = var.namespace
  create_namespace = false
  values           = var.argo_workflows_values

  depends_on = [kubernetes_namespace_v1.this]
}

resource "helm_release" "argo_events" {
  name             = "argo-events"
  repository       = var.argo_helm_repo
  chart            = "argo-events"
  version          = var.argo_events_chart_version
  namespace        = var.namespace
  create_namespace = false
  values           = var.argo_events_values

  depends_on = [kubernetes_namespace_v1.this]
}

# --- External Secrets Operator - IRSA-annotated controller reads Secrets Manager;
#     no serviceAccountRef in ClusterSecretStore. ---

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

# Traefik controller - required for gateway.yaml's IngressRoute/Middleware/ServersTransport CRDs.
resource "helm_release" "traefik" {
  count = var.install_traefik ? 1 : 0

  name             = "traefik"
  repository       = var.traefik_helm_repo
  chart            = "traefik"
  version          = var.traefik_chart_version
  namespace        = var.traefik_namespace
  create_namespace = false
}

# Several real pipeline manifests are multi-document YAML - yamldecode()
# only parses a single document, so each file is split on a bare "---"
# line first (same fix as the data-plane apps modules).
locals {
  manifest_documents = flatten([
    for idx, m in var.manifest_files : [
      for doc_idx, doc in [
        for chunk in split("\n---\n", "\n${templatefile(m.location, m.template_map)}") : chunk
        if trimspace(chunk) != ""
        ] : {
        key      = "${idx}-${doc_idx}"
        manifest = yamldecode(doc)
      }
    ]
  ])
}

resource "kubernetes_manifest" "this" {
  for_each = { for d in local.manifest_documents : d.key => d.manifest }

  manifest = each.value

  depends_on = [helm_release.nats, helm_release.argo_workflows, helm_release.argo_events, helm_release.traefik, helm_release.external_secrets]
}

# CRD-backed manifests applied via kubectl_manifest (not kubernetes_manifest) -
# avoids plan-time CRD schema validation that fails when the CRD installs in the same apply.
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

  depends_on = [helm_release.external_secrets, helm_release.nats, helm_release.argo_workflows, helm_release.argo_events]
}
