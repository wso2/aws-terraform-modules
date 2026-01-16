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

variable "eks_cluster_name" {
  type        = string
  description = "The name for the EKS Cluster"
}

variable "eks_cluster_abbreviation" {
  type        = string
  description = "The abbreviation for the EKS Cluster resource name"
  default     = "eks"
}

variable "iam_role_abbreviation" {
  type        = string
  description = "The abbreviation for the IAM Role resource name"
  default     = "ir"
}

variable "iam_policy_abbreviation" {
  type        = string
  description = "The abbreviation for the IAM Policy resource name"
  default     = "ip"
}

variable "route_table_abbreviation" {
  type        = string
  description = "The abbreviation for the Route Table resource name"
  default     = "rt"
}

variable "kubernetes_version" {
  type        = string
  description = "Kubernetes Version"
}
variable "endpoint_private_access" {
  type        = bool
  description = "Enable private access to Cluster"
  default     = true
}
variable "endpoint_public_access" {
  type        = bool
  description = "Enable public access to Cluster"
  default     = false
}
variable "public_access_cidrs" {
  type        = list(string)
  description = "Public CIDRs which can access the cluster API Server"
  default     = []
}
variable "service_ipv4_cidr" {
  type        = string
  description = "CIDR block for K8S Service"
}
variable "eks_vpc_id" {
  type        = string
  description = "ID of the VPC to create the subnets"
}
variable "subnet_details" {
  type = list(object({
    availability_zone = string
    cidr_block        = string
    custom_routes = list(object({
      cidr_block = string
      ep_type    = string
      ep_id      = string
    }))
  }))
  default = []
}
variable "secret_encryption_cmk" {
  type        = string
  description = "KMS Key ID for encrypting Kubernetes secrets"
  default     = null
}
variable "enabled_cluster_log_types" {
  type        = list(string)
  description = "List of cluster log types to enable"
  default     = []
}
variable "tags" {
  type        = map(string)
  description = "Tags to be associated with the EKS"
  default     = {}
}
variable "enable_ebs_csi_driver" {
  type        = bool
  description = "Enable EBS CSI Driver"
  default     = false
}
variable "enable_efs_csi_driver" {
  type        = bool
  description = "Enable EFS CSI Driver"
  default     = false
}
variable "enable_autoscaler" {
  type        = bool
  description = "Enable Cluster Autoscaler"
  default     = false
}
variable "enable_cluster_loadbalancer" {
  type        = bool
  description = "Enable Cluster Load Balancer"
  default     = false
}
variable "enable_fluent_bit" {
  type        = bool
  description = "Enable Fluent Bit"
  default     = false
}
variable "enable_cloudwatch_agent" {
  type        = bool
  description = "Enable CloudWatch Agent"
  default     = false
}
variable "cluster_iam_role_arn" {
  type        = string
  description = "IAM Role ARN for the EKS Cluster"
  default     = null
}
variable "cluster_subnet_ids" {
  type        = list(string)
  description = "Subnet IDs for the EKS Cluster"
  default     = []
}
variable "authentication_mode" {
  type        = string
  description = "EKS Cluster authentication mode"
  default     = "CONFIG_MAP"
}
variable "bootstrap_cluster_creator_admin_permissions" {
  type        = bool
  description = "Whether or not to bootstrap the access config values to the cluster"
  default     = false
}
variable "oidc_thumbprint_override" {
  type        = list(string)
  description = "This is to manually override the default thumbprint setting for the OIDC provider"
  default     = []
}
variable "subnet_abbreviation" {
  description = "Abbreviation for the subnet resource name"
  type        = string
  default     = "snet"
}
variable "subnet_name" {
  description = "Name for the subnet resource"
  type        = string
}
