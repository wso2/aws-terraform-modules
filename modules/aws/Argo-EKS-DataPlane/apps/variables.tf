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
# This module assumes the caller (the root/environment config) has already
# configured the kubernetes and helm providers against the cluster built by
# the sibling ../cluster module - it does not take cluster credentials as
# input, it inherits the providers implicitly like any other Terraform
# child module.
#
# This module is deliberately generic: it installs the upstream Argo
# Workflows/Events/ArgoCD charts, and applies whatever project-specific
# manifests (RBAC, EventSource/Sensor, ArgoCD Application/AppProject) the
# caller points it at via manifest_files. It does not hardcode any
# Asgardeo-specific YAML content itself, so it stays reusable beyond this
# one project.
#
# --------------------------------------------------------------------------------------

variable "namespaces" {
  type        = list(string)
  description = "Per-tier Kubernetes namespaces (e.g. [\"argo-stage\", \"argo-prod\"]) - created by this module, but Argo Workflows/Events themselves install once, cluster-wide, in system_namespace, not per entry here. RBAC (applied via manifest_files) is what actually isolates tiers, matching the security review doc's stated design."
}

variable "system_namespace" {
  type        = string
  description = "Namespace for the single shared argo-server/workflow-controller/argo-events install"
  default     = "argo"
}

variable "argo_workflows_chart_version" {
  type        = string
  description = "Argo Workflows Helm chart version. Null uses the chart repo's latest."
  default     = null
}

variable "argo_events_chart_version" {
  type        = string
  description = "Argo Events Helm chart version. Null uses the chart repo's latest."
  default     = null
}

variable "argo_helm_repo" {
  type        = string
  description = "Helm repository hosting the argo-workflows and argo-events charts"
  default     = "https://argoproj.github.io/argo-helm"
}

variable "argo_workflows_values" {
  type        = list(string)
  description = "Helm values overrides (YAML strings, later entries win) for the argo-workflows release. Set controller.workflowNamespaces to var.namespaces (or leave cluster-wide) depending on how narrow you want the watch."
  default     = []
}

variable "argo_events_values" {
  type        = list(string)
  description = "Helm values overrides (YAML strings, later entries win) for the argo-events release"
  default     = []
}

variable "install_argocd" {
  type        = bool
  description = "Whether to install ArgoCD on this cluster"
  default     = true
}

variable "argocd_namespace" {
  type        = string
  description = "Namespace for the ArgoCD installation"
  default     = "argocd"
}

variable "argocd_chart_version" {
  type        = string
  description = "ArgoCD Helm chart version. Null uses the chart repo's latest."
  default     = null
}

variable "argocd_helm_repo" {
  type        = string
  description = "Helm repository hosting the argo-cd chart"
  default     = "https://argoproj.github.io/argo-helm"
}

variable "argocd_values" {
  type        = list(string)
  description = "Helm values overrides (YAML strings, later entries win) for the argo-cd release"
  default     = []
}

variable "manifest_files" {
  type = list(object({
    location     = optional(string)
    content      = optional(string)
    template_map = optional(map(string), {})
    namespace    = optional(string)
  }))
  description = "Additional Kubernetes manifests to apply after the Helm releases above - e.g. debug-access RBAC, EventSource/Sensor definitions, ArgoCD Application/AppProject objects. Each entry is a template file path plus the variables to render it with; content and ordering are entirely caller-supplied, this module does not know what's in them. Set content directly to pass already-fetched text instead of rendering location as a local file path. namespace, if set, overrides every object's own embedded metadata.namespace via kubectl_manifest's override_namespace - lets one unmodified source file be applied into a different namespace per caller."
  default     = []
}

variable "install_external_secrets" {
  type        = bool
  description = "Install External Secrets Operator, syncing this data plane's own tier tokens from AWS Secrets Manager."
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
  }))
  description = "Manifests applied via the alekc/kubectl provider instead of kubernetes_manifest - required for anything backed by a CRD installed in this same apply (ESO's ClusterSecretStore/ExternalSecret). Set content directly to pre-process a real file's text instead of rendering location as-is."
  default     = []
}
