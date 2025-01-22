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
  description = "Name of the EKS cluster"
  type        = string
}

variable "eks_addon_name" {
  description = "Name of the EKS addon"
  type        = string
}

variable "eks_addon_version" {
  description = "Version of the EKS addon (optional). If set to null, allows the provider to use the default version"
  type        = string
  default     = null
}

variable "eks_addon_update_conflict" {
  description = "Strategy for resolving conflicts on addon update (optional). If set to null, allows the provider to use the default behavior"
  type        = string
  default     = null
}

variable "eks_addon_update_create" {
  description = "Strategy for resolving conflicts on addon creation (optional). If set to null, allows the provider to use the default behavior"
  type        = string
  default     = null
}

variable "eks_addon_configuration_values" {
  description = "Custom configuration values for the addon as a JSON string (optional)"
  type        = string
  default     = null
}
