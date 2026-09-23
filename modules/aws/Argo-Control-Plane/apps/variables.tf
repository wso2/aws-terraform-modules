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

variable "namespace" {
  type        = string
  description = "Kubernetes namespace for the control plane's Argo Workflows + Argo Events release"
  default     = "argo"
}

variable "extra_namespaces" {
  type        = list(string)
  description = "Additional namespaces to create beyond var.namespace (e.g. [\"oauth2-proxy\", \"gateway\"]), created before manifest_files/kubectl_manifest_files are applied."
  default     = []
}

variable "config_maps" {
  type = map(object({
    namespace = string
    data      = map(string)
  }))
  description = "ConfigMaps to create before manifest_files/kubectl_manifest_files are applied. Map key is the ConfigMap name; namespace must be var.namespace or one of extra_namespaces."
  default     = {}
}

variable "tunnel_client_identities" {
  type        = list(string)
  description = "One reverse-tunnel SSH keypair per data-plane identity (e.g. [\"aws\", \"azure\"]); private keys are exposed via tunnel_client_private_keys for out-of-band distribution. Default [] creates none."
  default     = []
}

variable "argo_workflows_chart_version" {
  type    = string
  default = null
}

variable "argo_events_chart_version" {
  type    = string
  default = null
}

variable "nats_chart_version" {
  type    = string
  default = null
}

variable "argo_helm_repo" {
  type    = string
  default = "https://argoproj.github.io/argo-helm"
}

variable "nats_helm_repo" {
  type    = string
  default = "https://nats-io.github.io/k8s/helm/charts/"
}

variable "argo_workflows_values" {
  type        = list(string)
  description = "Helm values overrides (YAML strings, later entries win) for argo-workflows. Should include workflow-controller replicas>=2 with leader election for HA."
  default     = []
}

variable "argo_events_values" {
  type        = list(string)
  description = "Helm values overrides (YAML strings, later entries win) for argo-events"
  default     = []
}

variable "nats_values" {
  type        = list(string)
  description = "Helm values overrides (YAML strings, later entries win) for the nats chart. Should set JetStream replicas=3 with anti-affinity across AZs and a PVC-backed store."
  default     = []
}

variable "install_cert_manager" {
  type        = bool
  description = "Install cert-manager and bootstrap a private client-CA for NATS mTLS client certs (this control plane's own, plus one per data plane). cert-manager renews before expiry automatically."
  default     = true
}

variable "cert_manager_chart_version" {
  type    = string
  default = null
}

variable "cert_manager_helm_repo" {
  type    = string
  default = "https://charts.jetstack.io"
}

variable "cert_manager_namespace" {
  type    = string
  default = "cert-manager"
}

variable "install_traefik" {
  type        = bool
  description = "Install the Traefik controller - required for gateway.yaml's Traefik-specific CRDs (IngressRoute, Middleware, ServersTransport)."
  default     = true
}

variable "traefik_chart_version" {
  type    = string
  default = null
}

variable "traefik_helm_repo" {
  type    = string
  default = "https://traefik.github.io/charts"
}

variable "traefik_values" {
  type        = list(string)
  description = "Helm values overrides for traefik. Must set providers.kubernetesCRD.allowExternalNameServices: true - gateway.yaml's backends are ExternalName Services, which Traefik refuses to route to by default."
  default     = []
}

variable "traefik_namespace" {
  type    = string
  default = "gateway"
}

variable "nats_server_external_dns_names" {
  type        = list(string)
  description = "Extra dnsNames for the nats-server-cert Certificate, beyond its two internal cluster-DNS names. Must include each data plane's own external NATS LoadBalancer hostname, or cross-cluster mTLS fails x509 SAN verification."
  default     = []
}

variable "nats_client_identities" {
  type        = list(string)
  description = "commonName for each data-plane NATS client certificate cert-manager issues, e.g. [\"azure-stage\", \"azure-prod\", \"aws-stage\", \"aws-prod\"]. Cert/key land in Secret \"nats-client-<entry>\", readable via nats_client_cert_pems/nats_client_key_pems for out-of-band distribution."
  default     = []
}

variable "manifest_files" {
  type = list(object({
    location     = optional(string)
    content      = optional(string)
    template_map = optional(map(string), {})
  }))
  description = "Additional Kubernetes manifests to apply - e.g. dispatch-namespace RBAC, the SSO gateway, Ingress/Service for the Load Balancer. Set content directly to pass already-fetched text instead of a location file path."
  default     = []
}

variable "install_external_secrets" {
  type        = bool
  description = "Install External Secrets Operator, used to sync the oauth2-proxy cookie-signing secret and SSO client secret from AWS Secrets Manager."
  default     = true
}

variable "eso_role_arn" {
  type        = string
  description = "IRSA role ARN for ESO's own controller ServiceAccount, from the cluster module's eso_role_arn output. Required when install_external_secrets is true."
  default     = null
}

variable "eso_chart_version" {
  type    = string
  default = null
}

variable "eso_helm_repo" {
  type    = string
  default = "https://charts.external-secrets.io"
}

variable "eso_namespace" {
  type    = string
  default = "external-secrets"
}

variable "kubectl_manifest_files" {
  type = list(object({
    location     = optional(string)
    content      = optional(string)
    template_map = optional(map(string), {})
    namespace    = optional(string)
  }))
  description = "Manifests applied via the kubectl provider instead of kubernetes_manifest - required for anything backed by a CRD installed in this same apply (e.g. ESO's ClusterSecretStore/ExternalSecret). namespace, if set, overrides each object's own metadata.namespace."
  default     = []
}
