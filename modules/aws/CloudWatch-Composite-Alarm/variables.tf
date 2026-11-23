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
  description = "Name of the composite alarm."
  type        = string
}

variable "description" {
  description = "Description of the composite alarm, sent with every notification."
  type        = string
  default     = null
}

variable "alarm_rule" {
  description = "Expression over other alarms' states that sets this alarm's state, for example ALARM(\"<arn-a>\") AND ALARM(\"<arn-b>\"). Alarms are named by name or ARN."
  type        = string

  validation {
    condition     = length(var.alarm_rule) > 0 && length(var.alarm_rule) <= 10240
    error_message = "alarm_rule must be between 1 and 10240 characters."
  }
}

variable "actions_enabled" {
  description = "Whether state changes run the actions."
  type        = bool
  default     = true
}

variable "alarm_actions" {
  description = "ARNs to notify when the composite alarm enters ALARM."
  type        = list(string)
  default     = []
}

variable "ok_actions" {
  description = "ARNs to notify when the composite alarm returns to OK."
  type        = list(string)
  default     = []
}

variable "insufficient_data_actions" {
  description = "ARNs to notify when the composite alarm enters INSUFFICIENT_DATA."
  type        = list(string)
  default     = []
}

variable "actions_suppressor" {
  description = "An alarm that, while in ALARM, holds back this alarm's actions: wait_period seconds for the suppressor to enter ALARM and extension_period seconds after it leaves."
  type = object({
    alarm            = string
    extension_period = number
    wait_period      = number
  })
  default = null
}

variable "tags" {
  description = "Tags to add to the composite alarm."
  type        = map(string)
  default     = {}
}
