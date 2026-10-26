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
  description = "Name of the project"
  type        = string
}

variable "application" {
  description = "Name of the application the distribution configuration belongs to"
  type        = string
}

variable "environment" {
  description = "Name of the environment"
  type        = string
}

variable "region" {
  description = "Code of the region"
  type        = string
}

variable "name" {
  description = "Optional short name that tells several distribution configurations of the same application apart"
  type        = string
  default     = null
}

variable "description" {
  description = "Description of the distribution configuration"
  type        = string
  default     = null
}

variable "distributions" {
  description = <<-EOT
    One entry per region the AMI is distributed to.
      ami_name           AMI name. Include {{ imagebuilder:buildDate }} to keep names unique across builds.
      kms_key_id         KMS key that encrypts the AMI in that region. Null keeps the source encryption.
      target_account_ids Accounts the AMI is copied to (they own the copy).
      launch_permission  Accounts, groups, organizations or OUs allowed to launch the AMI (it stays in this account).
  EOT
  type = list(object({
    region             = string
    ami_name           = optional(string)
    ami_description    = optional(string)
    kms_key_id         = optional(string)
    ami_tags           = optional(map(string), {})
    target_account_ids = optional(list(string), [])
    launch_permission = optional(object({
      user_ids                 = optional(list(string), [])
      user_groups              = optional(list(string), [])
      organization_arns        = optional(list(string), [])
      organizational_unit_arns = optional(list(string), [])
    }))
  }))

  validation {
    condition     = length(var.distributions) > 0
    error_message = "distributions must contain at least one region."
  }

  validation {
    condition     = length(distinct([for d in var.distributions : d.region])) == length(var.distributions)
    error_message = "distributions must not list the same region twice."
  }
}

variable "tags" {
  description = "Tags to be associated with the distribution configuration"
  type        = map(string)
  default     = {}
}
