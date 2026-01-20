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

variable "monitor_name" {
  description = "Name for the anomaly monitor."
  type        = string
}

variable "monitor_abbreviation" {
  description = "Abbreviation of the anomaly monitor"
  type        = string
  default     = "monitor"
}

variable "monitor_type" {
  description = "Type of anomaly monitor (e.g., DIMENSIONAL, CUSTOM)."
  type        = string
  default     = "DIMENSIONAL"
}

variable "monitor_dimension" {
  description = "Dimension for the anomaly monitor (e.g., SERVICE)."
  type        = string
  default     = "SERVICE"
}

variable "monitor_subscription_name" {
  description = "Name for the anomaly subscription."
  type        = string
}

variable "monitor_subscription_abbreviation" {
  description = "Abbreviation of the cost anomaly monitor subscription"
  type        = string
  default     = "sub"
}

variable "threshold" {
  description = "Threshold for anomaly alerts."
  type        = number
  default     = 100
}

variable "threshold_key" {
  description = "Thershold key for anomaly alerts"
  type        = string
  default     = "ANOMALY_TOTAL_IMPACT_ABSOLUTE"
}

variable "threshold_match_options" {
  description = "Threshold match options for alerts"
  type        = list(string)
  default     = ["GREATER_THAN_OR_EQUAL"]
}

variable "frequency" {
  description = "Notification frequency (e.g., IMMEDIATE, DAILY)."
  type        = string
  default     = "IMMEDIATE"
}

variable "subscriber_type" {
  description = "Type of subscriber (e.g., EMAIL)."
  type        = string
  default     = "EMAIL"
}

variable "subscriber_address" {
  description = "Address for anomaly notifications."
  type        = string
}
