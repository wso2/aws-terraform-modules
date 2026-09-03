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

resource "kubernetes_namespace_v1" "namespace" {
  metadata {
    name = var.namespace
  }
}

# Reverse-tunnel SSH keypairs, one per data-plane identity - same
# per-identity generation pattern as the NATS client certs below, just
# raw SSH keys (tls provider) instead of cert-manager Certificates,
# since tunnel-server.yaml speaks plain SSH, not TLS.
resource "tls_private_key" "tunnel_client" {
  for_each = toset(var.tunnel_client_identities)

  algorithm = "ED25519"
}

locals {
  tunnel_authorized_keys = join("\n", [
    for identity, key in tls_private_key.tunnel_client :
    "command=\"/bin/false\",no-pty,no-agent-forwarding,no-x11-forwarding ${trimspace(key.public_key_openssh)} ${identity}-dp-tunnel"
  ])
}

resource "kubernetes_secret_v1" "tunnel_server_authorized_keys" {
  count = length(var.tunnel_client_identities) > 0 ? 1 : 0

  metadata {
    name      = "tunnel-server-authorized-keys"
    namespace = var.namespace
  }
  data = {
    "authorized_keys" = local.tunnel_authorized_keys
  }

  depends_on = [kubernetes_namespace_v1.namespace]
}

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
      duration   = "8760h"
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
      duration    = "2160h"
      renewBefore = "360h"
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

data "kubernetes_secret_v1" "nats_client_certificate" {
  for_each = var.install_cert_manager ? toset(var.nats_client_identities) : []

  metadata {
    name      = "nats-client-${each.value}-secret"
    namespace = var.namespace
  }

  depends_on = [kubectl_manifest.nats_client_certificate]
}

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

  depends_on = [kubernetes_namespace_v1.namespace, kubectl_manifest.nats_server_certificate, kubernetes_storage_class_v1.gp3]
}

resource "helm_release" "argo_workflows" {
  name             = "argo-workflows"
  repository       = var.argo_helm_repo
  chart            = "argo-workflows"
  version          = var.argo_workflows_chart_version
  namespace        = var.namespace
  create_namespace = false
  values           = var.argo_workflows_values

  depends_on = [kubernetes_namespace_v1.namespace]
}

resource "helm_release" "argo_events" {
  name             = "argo-events"
  repository       = var.argo_helm_repo
  chart            = "argo-events"
  version          = var.argo_events_chart_version
  namespace        = var.namespace
  create_namespace = false
  values           = var.argo_events_values

  depends_on = [kubernetes_namespace_v1.namespace]
}

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

resource "helm_release" "traefik" {
  count = var.install_traefik ? 1 : 0

  name             = "traefik"
  repository       = var.traefik_helm_repo
  chart            = "traefik"
  version          = var.traefik_chart_version
  namespace        = var.traefik_namespace
  create_namespace = false
}

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

resource "kubernetes_manifest" "kubernetes_object" {
  for_each = { for d in local.manifest_documents : d.key => d.manifest }

  manifest = each.value

  depends_on = [helm_release.nats, helm_release.argo_workflows, helm_release.argo_events, helm_release.traefik, helm_release.external_secrets]
}

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
