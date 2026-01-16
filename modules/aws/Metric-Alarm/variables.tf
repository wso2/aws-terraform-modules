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

variable "metric_namespace" {
  description = "The namespace for the CloudWatch metric"
  type        = string
}
variable "metric_name" {
  description = "The name of the CloudWatch metric"
  type        = string
}
variable "alarm_actions" {
  description = "The ARNs of the actions to take when the alarm changes state"
  type        = list(string)
}
variable "insufficient_data_actions" {
  description = "The ARNs of the actions to take when the alarm changes state into insufficient data"
  type        = list(string)
  default     = []
}
variable "ok_actions" {
  description = "The ARNs of the actions to take when the alarm changes state into OK"
  type        = list(string)
  default     = []
}
variable "unit" {
  description = "The unit for the metric"
  type        = string
  default     = null
}
variable "comparison_operator" {
  description = "The comparison operator for the alarm"
  type        = string
}
variable "evaluation_periods" {
  description = "The number of periods over which to evaluate the alarm"
  type        = number
  default     = 1
}
variable "period" {
  description = "The period in seconds over which to evaluate the alarm"
  type        = number
  default     = 60
}
variable "threshold" {
  description = "The threshold for the alarm"
  type        = number
}
variable "alarm_description" {
  description = "The description of the alarm"
  type        = string
}
variable "dimensions" {
  description = "The dimensions for the metric"
  type        = map(string)
  default     = null
}
variable "statistic" {
  description = "The statistic for the metric"
  type        = string
  default     = null
}
variable "enabled" {
  description = "Whether the alarm should be enabled"
  type        = bool
  default     = true
}
variable "extended_statistic" {
  description = "The percentile statistic for the metric"
  type        = string
  default     = null
}

variable "alarm_name" {
  type        = string
  description = "The name for the CloudWatch Metric Alarm"
}

variable "alarm_abbreviation" {
  type        = string
  description = "The abbreviation for the Metric Alarm resource name"
  default     = "cwa"
}

variable "tags" {
  type        = map(string)
  description = "Tags to be attached to the resource"
  default     = {}
}
