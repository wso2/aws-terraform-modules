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

variable "topic_name" {
  type        = string
  description = "The name of the SNS topic"
}
variable "project" {
  type        = string
  description = "Name of the project"
}
variable "environment" {
  type        = string
  description = "Name of the environment"
}
variable "region" {
  type        = string
  description = "Code of the region"
}
variable "application" {
  type        = string
  description = "Purpose of the Subnet"
}
variable "subscribers" {
  description = "A list of subscribers for the SNS topic"
  type = list(object({
    protocol               = string
    endpoint               = string
    raw_message_delivery   = optional(bool, false)
    filter_policy          = optional(string)
    filter_policy_scope    = optional(string, "MessageAttributes")
    endpoint_auto_confirms = optional(bool, false)
    delivery_policy        = optional(string)
  }))
}
variable "tags" {
  type        = map(string)
  description = "Tags to be added to the security group"
  default     = {}
}
variable "kms_master_key_id" {
  type        = string
  description = "The ID of an AWS-managed customer master key (CMK) for Amazon SNS or a custom CMK"
  default     = null
}
variable "topic_policy_json" {
  type        = string
  description = "The JSON policy to apply to the SNS topic"
  default     = null
}
