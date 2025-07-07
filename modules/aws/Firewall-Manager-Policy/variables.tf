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

variable "project" {
  description = "Project name"
  type        = string
}
variable "environment" {
  description = "Environment name"
  type        = string
}
variable "application" {
  description = "Application name"
  type        = string
}
variable "region" {
  description = "AWS region to deploy the resources"
  type        = string
}
variable "exclude_resource_tags" {
  description = "Exclude resources with specific tags from the policy"
  type        = bool
  default     = false
}
variable "enable_remediation" {
  description = "Enable remediation for the policy"
  type        = bool
  default     = true
}
variable "resource_type" {
  description = "Type of resource to be managed by the policy"
  type        = string
  default     = null
}
variable "resource_type_list" {
  description = "List of resource types to be managed by the policy"
  type        = list(string)
  default     = null
}
variable "delete_all_policy_resources" {
  description = "Delete all resources associated with the policy"
  type        = bool
  default     = false
}
variable "delete_unused_fm_managed_resources" {
  description = "Delete unused Firewall Manager managed resources"
  type        = bool
  default     = false
}
variable "included_account_list" {
  description = "List of accounts to include in the policy"
  type        = list(string)
  default     = []
}
variable "included_organizational_unit_list" {
  description = "List of organizational units to include in the policy"
  type        = list(string)
  default     = []
}
variable "security_service_policy_data_type" {
  description = "Type of security service policy data"
  type        = string
  default     = "AWS_WAF"
}
variable "managed_service_data" {
  description = "Managed service data for the security service policy"
  type        = string
  default     = null
}
variable "tags" {
  description = "Tags to be applied to the Firewall Manager policy"
  type        = map(string)
  default     = {}
}
