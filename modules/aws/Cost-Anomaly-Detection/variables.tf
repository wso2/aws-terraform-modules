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
  description = "Abbreviation of the anomaly monitor."
  type        = string
  default     = "monitor"
}
variable "monitor_type" {
  description = "Type of anomaly monitor (DIMENSIONAL or CUSTOM)."
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
  description = "Abbreviation of the cost anomaly monitor subscription."
  type        = string
  default     = "sub"
}
variable "frequency" {
  description = "Notification frequency (IMMEDIATE, DAILY, or WEEKLY)."
  type        = string
  default     = "IMMEDIATE"
}
variable "subscriber_type" {
  description = "Type of subscriber (SNS or EMAIL)."
  type        = string
  default     = "SNS"
}
variable "subscriber_address" {
  description = "SNS topic ARN or email address for anomaly notifications."
  type        = string
}
variable "absolute_threshold" {
  description = "Minimum absolute $ impact the anomaly must reach to trigger an alert."
  type        = number
  default     = 20
}
variable "percentage_threshold" {
  description = "Minimum % above expected spend the anomaly must reach to trigger an alert."
  type        = number
  default     = 15
}