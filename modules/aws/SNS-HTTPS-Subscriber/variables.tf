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

variable "sns_arn" {
  description = "The ARN of the SNS topic to subscribe to."
  type        = string
}

variable "endpoint" {
  description = "HTTPS URL that SNS will POST notifications to. Basic-auth credentials may be embedded (https://user:pass@host/path); the caller is responsible for URL-encoding."
  type        = string
  sensitive   = true
}

variable "endpoint_auto_confirms" {
  description = "When true, SNS treats the initial SubscriptionConfirmation as an application/json body that the endpoint auto-confirms. Set to true for endpoints that respond to the confirmation automatically (e.g. ServiceNow)."
  type        = bool
  default     = true
}

variable "raw_message_delivery" {
  description = "When false (default), SNS wraps published messages in the standard SNS envelope. Leave false for endpoints that expect the SNS JSON envelope (e.g. ServiceNow)."
  type        = bool
  default     = false
}

variable "delivery_policy" {
  description = "JSON string containing the subscription's delivery policy. Use to set healthy retry parameters and requestPolicy.headerContentType (e.g. application/json). When null, the topic's default delivery policy applies."
  type        = string
  default     = null
}
