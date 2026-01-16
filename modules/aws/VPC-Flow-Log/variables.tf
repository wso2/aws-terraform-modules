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

variable "log_destination" {
  type        = string
  description = "The log destination for Flow Log"
}
variable "log_destination_type" {
  type        = string
  description = "The log destination type for Flow Log"
}
variable "traffic_type" {
  type        = string
  description = "The traffic type for Flow Log"
}
variable "vpc_id" {
  type        = string
  description = "The VPC ID which is associated with the Flow Log"
  default     = null
}
variable "subnet_id" {
  type        = string
  description = "The Subnet ID which is associated with the Flow Log"
  default     = null
}
variable "tags" {
  type        = map(string)
  description = "The tags for Flow Log"
}
variable "eni_id" {
  type        = string
  description = "The ENI ID which is associated with the Flow Log"
  default     = null
}
variable "transit_gateway_id" {
  type        = string
  description = "The Transit Gateway ID which is associated with the Flow Log"
  default     = null
}
variable "transit_gateway_attachment_id" {
  type        = string
  description = "The Transit Gateway Attachment ID which is associated with the Flow Log"
  default     = null
}
variable "log_format" {
  type        = string
  description = "The log format for Flow Log"
  default     = null
}
variable "max_aggregation_interval" {
  type        = number
  description = "The maximum interval of time during which a flow of packets is captured and aggregated into a flow log record. Measured in seconds"
  default     = 600
}
variable "vpc_flow_log_abbreviation" {
  description = "The abbreviation for the VPC Flow Log"
  type        = string
}

variable "vpc_flow_log_name" {
  description = "The name for the VPC Flow Log"
  type        = string
  default     = "flowlog"
}

variable "iam_role_abbreviation" {
  description = "The abbreviation for the IAM role resource name"
  type        = string
  default     = "vflir"
}

variable "iam_policy_abbreviation" {
  description = "The abbreviation for the IAM policy resource name"
  type        = string
  default     = "vflip"
}
