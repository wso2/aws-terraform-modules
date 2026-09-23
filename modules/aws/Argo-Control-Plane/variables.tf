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
# Straight passthrough into module.cluster or module.apps (see main.tf),
# except apps' eso_role_arn, which is auto-wired instead of exposed here.
#
# --------------------------------------------------------------------------------------

# --- Passed to module.cluster ---

variable "project" {
  type        = string
  description = "Name of the project (used for resource naming/tagging)"
}

variable "environment" {
  type        = string
  description = "Name of the environment"
  default     = "prod"
}

variable "region" {
  type        = string
  description = "Code of the AWS region"
}

variable "application" {
  type        = string
  description = "Purpose tag for the resources created by this module"
  default     = "argo-controlplane"
}

variable "tags" {
  type        = map(string)
  description = "Tags applied to all resources created by this module"
  default     = {}
}

variable "vpc_cidr_block" {
  type        = string
  description = "CIDR block for the control plane's VPC"
}

variable "availability_zones" {
  type        = list(string)
  description = "Availability zones for the control plane's VPC. NATS JetStream runs 3 replicas across these regardless of AZ count; use at least 3 AZs for real node-level HA."
}

variable "private_subnet_cidr_blocks" {
  type        = list(string)
  description = "One CIDR per AZ for the private (node) subnets, same order as availability_zones"
}

variable "public_subnet_cidr_blocks" {
  type        = list(string)
  description = "One CIDR per AZ for the public (NAT Gateway) subnets, same order as availability_zones"
}

variable "kubernetes_version" {
  type        = string
  description = "Kubernetes version for the EKS cluster"
}

variable "endpoint_public_access" {
  type        = bool
  description = "Whether the EKS API server has a public endpoint"
  default     = false
}

variable "public_access_cidrs" {
  type        = list(string)
  description = "CIDRs allowed to reach the public API endpoint, if enabled"
  default     = []
}

variable "admin_principal_arns" {
  type        = list(string)
  description = "IAM principal ARNs (users/roles) granted EKS cluster-admin access entries (native-IAM cluster access path)"
  default     = []
}

variable "enable_secrets_encryption" {
  type        = bool
  description = "Whether to create a dedicated KMS CMK and envelope-encrypt Kubernetes Secrets with it"
  default     = false
}

variable "enabled_cluster_log_types" {
  type        = list(string)
  description = "List of cluster log types to enable - when non-empty, a matching CloudWatch Log Group is also created with retention set by log_retention_in_days"
  default     = []
}

variable "log_retention_in_days" {
  type        = number
  description = "Retention for any CloudWatch Log Groups this module creates (EKS cluster logs, VPC flow logs) and the S3 artifact bucket's expiration, if enabled"
  default     = 90
}

variable "enable_vpc_flow_logs" {
  type        = bool
  description = "Whether to create a VPC Flow Log for this module's own VPC, published to a dedicated CloudWatch Log Group"
  default     = false
}

variable "enable_artifact_archiving" {
  type        = bool
  description = "Whether to create an S3 bucket + IRSA role for Argo Workflows to archive workflow logs/artifacts to. Wire the two outputs into argo_workflows_values' artifactRepository config."
  default     = false
}

variable "argo_namespace" {
  type        = string
  description = "Kubernetes namespace Argo Workflows runs in - only used to scope the workflow-controller's IRSA trust policy when enable_artifact_archiving is true"
  default     = "argo"
}

variable "workflow_controller_service_account_name" {
  type        = string
  description = "ServiceAccount name the argo-workflows Helm chart creates for workflow-controller - only used to scope the IRSA trust policy when enable_artifact_archiving is true"
  default     = "argo-workflows-workflow-controller"
}

variable "eks_addons" {
  type = list(object({
    name    = string
    version = optional(string)
  }))
  description = "Core EKS addons to install alongside the EBS CSI driver below"
  default = [
    { name = "vpc-cni" },
    { name = "coredns" },
    { name = "kube-proxy" },
  ]
}

variable "node_instance_types" {
  type        = list(string)
  description = "Instance types for the shared node group"
}

variable "node_min_size" {
  type        = number
  description = "Minimum node count for the shared node group's scaling_config"
  default     = 2
}

variable "node_max_size" {
  type        = number
  description = "Maximum node count for the shared node group's scaling_config"
  default     = 4
}

variable "node_desired_size" {
  type        = number
  description = "Desired node count for the shared node group's scaling_config"
  default     = 2
}

variable "node_capacity_type" {
  type        = string
  description = "Capacity type for the shared node group (ON_DEMAND or SPOT)"
  default     = "ON_DEMAND"
}

variable "security_group_rules" {
  type = list(object({
    direction       = string
    to_port         = number
    from_port       = number
    protocol        = string
    cidr_blocks     = list(string)
    security_groups = list(string)
  }))
  description = "Additional security group rules, beyond the EKS-managed cluster security group"
  default     = []
}

variable "enable_bastion" {
  type        = bool
  description = "Whether to provision a bastion instance for admin access, via AWS Systems Manager Session Manager - no inbound security group rules, no open port."
  default     = true
}

variable "bastion_instance_type" {
  type        = string
  description = "EC2 instance type for the bastion instance, when enable_bastion is true"
  default     = "t3.micro"
}

variable "eso_secretsmanager_key_prefix" {
  type        = string
  description = "Secrets Manager key-name prefix (glob) the eso IAM role may read, scoped to this control plane's own secrets."
  default     = "argo/control-plane/*"
}

# --- Passed to module.apps (eso_role_arn intentionally NOT here - see main.tf) ---

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
