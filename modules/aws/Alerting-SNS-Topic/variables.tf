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

variable "sns_topic_name" {
  type        = string
  description = "The name for the SNS Topic"
}

variable "sns_topic_abbreviation" {
  type        = string
  description = "The abbreviation for the SNS Topic resource name"
  default     = "sns"
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
