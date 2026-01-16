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

variable "target_group_name" {
  type        = string
  description = "The name for the Load Balancer Target Group"
}

variable "target_group_abbreviation" {
  type        = string
  description = "The abbreviation for the Target Group resource name"
  default     = "tg"
}

variable "target_type" {
  type        = string
  description = "Type of the target"
}
variable "port" {
  type        = number
  description = "Primary port to be exposed within the Target Group"
}
variable "protocol" {
  type        = string
  description = "Protocol to be used for the Target Group"
}
variable "vpc_id" {
  type        = string
  description = "VPC ID"
}
variable "target_group_attachments" {
  type = map(object({
    target_id         = string
    availability_zone = optional(string)
    port              = optional(number)
  }))
  description = "List of target group attachments"
}
variable "tags" {
  type        = map(string)
  description = "Tags to be added to the resources"
  default     = {}
}
