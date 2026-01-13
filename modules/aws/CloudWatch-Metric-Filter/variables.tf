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

variable "name" {
  description = "The name of the metric filter"
  type        = string
}

variable "log_group_name" {
  description = "The name of the log group to create the metric filter on"
  type        = string
}

variable "pattern" {
  description = "A valid CloudWatch Logs filter pattern for extracting metric data"
  type        = string
}

variable "metric_name" {
  description = "The name of the CloudWatch metric"
  type        = string
}

variable "metric_namespace" {
  description = "The destination namespace of the CloudWatch metric"
  type        = string
}

variable "metric_value" {
  description = "The value to publish to the CloudWatch metric"
  type        = string
  default     = "1"
}

variable "metric_unit" {
  description = "The unit to assign to the metric"
  type        = string
  default     = "Count"
}

variable "metric_default_value" {
  description = "The value to emit when a filter pattern does not match a log event"
  type        = number
  default     = null
}

variable "metric_dimensions" {
  description = "Map of dimensions for the metric"
  type        = map(string)
  default     = {}
}
