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

variable "name" {
  description = "The name of the rule"
  type        = string
}

variable "description" {
  description = "The description of the rule"
  type        = string
  default     = null
}

variable "event_pattern" {
  description = "The event pattern described as a JSON string. Either this or schedule_expression must be specified"
  type        = string
  default     = null
}

variable "schedule_expression" {
  description = "The scheduling expression (e.g., cron(0 20 * * ? *) or rate(5 minutes)). Either this or event_pattern must be specified"
  type        = string
  default     = null
}

variable "state" {
  description = "The state of the rule"
  type        = string
  default     = "ENABLED"
}

variable "role_arn" {
  description = "The Amazon Resource Name (ARN) associated with the role that is used for target invocation"
  type        = string
  default     = null
}

variable "tags" {
  description = "A map of tags to assign to the resource"
  type        = map(string)
  default     = {}
}
