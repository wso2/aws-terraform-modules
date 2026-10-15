# -------------------------------------------------------------------------------------
#
# Copyright (c) 2025, WSO2 LLC. (https://www.wso2.com) All Rights Reserved.
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
  description = "The name of the EKS cluster"
  type        = string
}

variable "principal_arn" {
  description = "The ARN of the principal to associate the policy with"
  type        = string
}

variable "policy_arn" {
  description = "The ARN of the access policy (e.g., arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy)"
  type        = string
}

variable "type" {
  description = "The type of the access scope (cluster or namespace)"
  type        = string
  default     = "cluster"
}

variable "namespace" {
  description = "List of namespaces for namespace-scoped policies"
  type        = list(string)
  default     = null
}
