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
  description = "Availability zones for the control plane's multi-AZ layout - a config choice, not fixed by this module. NATS JetStream itself still runs 3 replicas regardless of AZ count (set via the apps module); with fewer than 3 AZs, a single-AZ outage can take out a majority of those replicas and break quorum - an inherent property of RAFT, not something more AZs-per-node fixes on its own. 2 is the practical minimum for any node-level HA at all."

  validation {
    condition     = length(var.availability_zones) >= 2
    error_message = "At least 2 AZs are required for basic node-level HA - a single AZ makes this module's whole per-AZ NAT Gateway/subnet design pointless."
  }
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

variable "secret_encryption_cmk" {
  type        = string
  description = "KMS Key ARN for encrypting Kubernetes secrets"
  default     = null
}

variable "enabled_cluster_log_types" {
  type        = list(string)
  description = "List of cluster log types to enable"
  default     = []
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
  type    = number
  default = 2
}

variable "node_max_size" {
  type    = number
  default = 4
}

variable "node_desired_size" {
  type    = number
  default = 2
}

variable "node_capacity_type" {
  type    = string
  default = "ON_DEMAND"
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
  type    = string
  default = "t3.micro"
}

variable "eso_secretsmanager_key_prefix" {
  type        = string
  description = "Secrets Manager key-name prefix (glob) the eso IAM role may read - scoped to this control plane's own secrets, matching the security review doc's stated scoping (\"IAM-scoped to argo/control-plane/*\") for the oauth2-proxy cookie-signing secret and the SSO client secret."
  default     = "argo/control-plane/*"
}
