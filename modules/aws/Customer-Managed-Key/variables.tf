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

variable "kms_key_name" {
  type        = string
  description = "The name for the KMS Key"
}

variable "kms_key_abbreviation" {
  type        = string
  description = "The abbreviation for the KMS Key resource name"
  default     = "cmk"
}

variable "tags" {
  type        = map(string)
  description = "The tags for the resources"
  default     = {}
}
variable "key_usage" {
  type        = string
  description = "The intended use of the key. Valid values: ENCRYPT_DECRYPT or SIGN_VERIFY"
  default     = "ENCRYPT_DECRYPT"
}
variable "deletion_window_in_days" {
  type        = number
  description = "Duration in days after which the key is deleted after destruction of the resource, must be between 7 and 30 days"
  default     = 30
}
variable "description" {
  type        = string
  description = "The description of the key as viewed in AWS console"
  default     = "KMS key for WSO2 API Manager"
}
variable "policy" {
  type        = string
  description = "The policy of the key as viewed in AWS console"
  default     = null
}
variable "is_enabled" {
  type        = bool
  description = "Specifies whether the key is enabled. Defaults to true."
  default     = true
}
variable "is_multi_region" {
  type        = bool
  description = "Specifies whether the key is multi-region. Defaults to false."
  default     = false
}
variable "enable_key_rotation" {
  type        = bool
  description = "Specifies whether key rotation is enabled. Defaults to false."
  default     = true
}
