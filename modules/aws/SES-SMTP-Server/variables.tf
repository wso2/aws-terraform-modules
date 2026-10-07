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

variable "project" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Name of the environment"
  type        = string
}

variable "region" {
  description = "Shortened code of the region, used for naming only"
  type        = string
}

variable "aws_region" {
  description = "Full AWS region (e.g. ap-southeast-2) SES sends from and the SMTP password is derived for"
  type        = string
}

variable "application" {
  description = "Purpose/application name, used for naming"
  type        = string
  default     = "ses-smtp"
}

variable "domain_name" {
  description = "Domain to verify and send mail from (e.g. notifications.example.com)"
  type        = string
}

variable "mail_from_subdomain" {
  description = "Subdomain label to use as a custom MAIL FROM domain (e.g. \"mail\" -> mail.<domain_name>). Set null to skip and use the default amazonses.com MAIL FROM domain."
  type        = string
  default     = null
}

variable "enable_event_destination" {
  description = "Whether to create a configuration set publishing bounce/complaint events to sns_topic_arn"
  type        = bool
  default     = true
}

variable "event_destination_matching_types" {
  description = "SES event types published to sns_topic_arn when enable_event_destination is true"
  type        = list(string)
  default     = ["BOUNCE", "COMPLAINT"]
}

variable "dkim_signing_key_length" {
  description = "DKIM signing key length for the domain identity"
  type        = string
  default     = "RSA_2048_BIT"
  validation {
    condition     = contains(["RSA_1024_BIT", "RSA_2048_BIT"], var.dkim_signing_key_length)
    error_message = "dkim_signing_key_length must be \"RSA_1024_BIT\" or \"RSA_2048_BIT\"."
  }
}

variable "sns_topic_arn" {
  description = "SNS topic ARN to publish bounce/complaint events to. Required when enable_event_destination is true."
  type        = string
  default     = null
}

variable "tags" {
  description = "A map of tags to assign to the resources"
  type        = map(string)
  default     = {}
}
