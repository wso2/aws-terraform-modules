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

variable "project" {
  type        = string
  description = "Name of the project (used for resource naming/tagging)"
}

variable "environment" {
  type        = string
  description = "Name of the environment (e.g. dev, stage, prod)"
}

variable "region" {
  type        = string
  description = "Code of the AWS region"
}

variable "application" {
  type        = string
  description = "Purpose tag for the resources created by this module"
  default     = "argo-dataplane"
}

variable "tags" {
  type        = map(string)
  description = "Tags applied to all resources created by this module"
  default     = {}
}

variable "vpc_cidr_block" {
  type        = string
  description = "CIDR block for the data plane's VPC"
}

variable "stage_public_subnet_cidr_block" {
  type        = string
  description = "CIDR block for the public subnet hosting the stage tier's NAT Gateway. Placed in the first AZ of stage_availability_zones."
}

variable "prod_public_subnet_cidr_block" {
  type        = string
  description = "CIDR block for the public subnet hosting the prod tier's NAT Gateway. Placed in the first AZ of prod_availability_zones."
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
  description = "IAM principal ARNs (users/roles) granted EKS cluster-admin access entries. This is the native-IAM cluster access path (no unified cross-cloud identity layer)."
  default     = []
}

variable "eks_addons" {
  type = list(object({
    name    = string
    version = optional(string)
  }))
  description = "Core EKS addons to install (e.g. vpc-cni, coredns, kube-proxy)"
  default = [
    { name = "vpc-cni" },
    { name = "coredns" },
    { name = "kube-proxy" },
  ]
}

# --- Stage tier ---

variable "stage_availability_zones" {
  type        = list(string)
  description = "Availability zones for the stage subnet(s)"
}

variable "stage_subnet_cidr_blocks" {
  type        = list(string)
  description = "CIDR blocks for the stage subnet(s), one per availability zone"
}

variable "stage_node_instance_types" {
  type        = list(string)
  description = "Instance types for the stage node group"
}

variable "stage_node_min_size" {
  type    = number
  default = 1
}

variable "stage_node_max_size" {
  type    = number
  default = 3
}

variable "stage_node_desired_size" {
  type    = number
  default = 2
}

variable "stage_node_capacity_type" {
  type    = string
  default = "ON_DEMAND"
}

variable "stage_security_group_rules" {
  type = list(object({
    direction       = string
    to_port         = number
    from_port       = number
    protocol        = string
    cidr_blocks     = list(string)
    security_groups = list(string)
  }))
  description = "Additional security group rules for the stage tier, beyond the EKS-managed cluster security group"
  default     = []
}

# --- Prod tier ---

variable "prod_availability_zones" {
  type        = list(string)
  description = "Availability zones for the prod subnet(s)"
}

variable "prod_subnet_cidr_blocks" {
  type        = list(string)
  description = "CIDR blocks for the prod subnet(s), one per availability zone"
}

variable "prod_node_instance_types" {
  type        = list(string)
  description = "Instance types for the prod node group"
}

variable "prod_node_min_size" {
  type    = number
  default = 1
}

variable "prod_node_max_size" {
  type    = number
  default = 3
}

variable "prod_node_desired_size" {
  type    = number
  default = 2
}

variable "prod_node_capacity_type" {
  type    = string
  default = "ON_DEMAND"
}

variable "prod_security_group_rules" {
  type = list(object({
    direction       = string
    to_port         = number
    from_port       = number
    protocol        = string
    cidr_blocks     = list(string)
    security_groups = list(string)
  }))
  description = "Additional security group rules for the prod tier, beyond the EKS-managed cluster security group"
  default     = []
}

variable "prod_node_taint_value" {
  type        = string
  description = "Value for the env taint applied to prod nodes (key is fixed to \"env\", effect fixed to NO_SCHEDULE) so only workloads that explicitly tolerate it land in prod"
  default     = "prod"
}

variable "enable_bastion" {
  type        = bool
  description = "Whether to provision a bastion instance for admin access to this data plane, via AWS Systems Manager Session Manager - no inbound security group rules, no open port, matching Azure Bastion's zero-inbound property. Uses the stage private subnet's existing NAT egress to reach the SSM service endpoint."
  default     = true
}

variable "bastion_instance_type" {
  type    = string
  default = "t3.micro"
}

variable "eso_secretsmanager_key_prefix" {
  type        = string
  description = "Secrets Manager key-name prefix (glob) the eso IAM role may read. Defaults to \"*\" because this data plane's real ExternalSecrets (the IS-deploy pipeline's tier tokens) reference bare, unprefixed key names copied from an existing Azure Key Vault store - narrow this if/when those keys are ever renamed onto a path convention."
  default     = "*"
}

variable "deploy_identities" {
  type = map(object({
    namespace            = string
    service_account_name = string
    policy_json          = string
  }))
  description = "Per-env IRSA identities for pipeline pods (\"Pipeline pod -> deployment target: Cloud-native Workload Identity Federation / IRSA, scoped per env\" per the security review doc) - no standing secret, credential minted per-pod by AWS itself. One IAM role per map entry, trusted via this cluster's own OIDC provider and scoped to exactly that (namespace, ServiceAccount) pair. policy_json is caller-supplied (this module has no opinion on what a pipeline actually needs to reach - e.g. {\"stage\" = {namespace=\"argo-stage\", service_account_name=\"is-deploy-stage\", policy_json=...}})."
  default     = {}
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
  description = "Whether to create an S3 bucket + IRSA role for Argo Workflows to archive workflow logs/artifacts to (workflow_controller_artifacts_role_arn/artifact_bucket_name outputs). The caller still wires these into argo_workflows_values' artifactRepository Helm config."
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
