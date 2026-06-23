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

# Script  variables read by env-create.sh and also passed to Terraform

variable "project" {
  description = "Project name"
  type        = string
}

variable "deployment_environment" {
  description = "Deployment environment (e.g. rnd, prod)"
  type        = string
}

variable "deployment_layer" {
  description = "Deployment layer / application name (e.g. scanner)"
  type        = string
}

# Infrastructure variables

variable "aws_region" {
  description = "AWS region to deploy resources into"
  type        = string
  default     = "us-east-1"
}

variable "account_name" {
  description = "Human-readable name of the AWS account (used for tagging only)"
  type        = string
}

variable "report_bucket_name" {
  description = "Name of the S3 bucket where CSV reports are stored"
  type        = string
}

variable "sender_email" {
  description = "SES-verified sender email address"
  type        = string
}

variable "ses_region" {
  # Region used to send the SES report. Empty = use aws_region; set only if SES
  # is verified in a different region.
  description = "Region used for SES SendEmail; defaults to aws_region when empty"
  type        = string
  default     = ""
}

variable "recipient_emails" {
  description = "Comma-separated list of recipient email addresses"
  type        = string
}

variable "regions" {
  description = "Comma-separated list of AWS regions to scan. Leave empty to auto-discover all enabled regions per account."
  type        = string
  default     = ""
}


variable "excluded_resource_ids" {
  description = "Resource IDs the scanner should never report (e.g. vol-0abc123, eipalloc-0def456). Edit this list and run terraform apply to change exclusions."
  type        = list(string)
  default     = []
}

variable "lambda_timeout" {
  description = "Lambda timeout in seconds"
  type        = number
  default     = 900
}

variable "lambda_memory_size" {
  description = "Lambda memory in MB. 128 OOMs on multi-account scans; 1024 gives headroom + faster CPU."
  type        = number
  default     = 1024
}

variable "report_retention_days" {
  description = "Days before old reports are automatically deleted by S3 lifecycle rule"
  type        = number
  default     = 90
}

variable "scan_hub_account" {
  description = "Scan the account the Lambda runs in (the hub) with its own credentials, in addition to any cross-account target roles."
  type        = bool
  default     = true
}

variable "target_role_arns" {
  description = "ARNs of pre-existing read-only IAM roles in the accounts to assume and scan. Each role must trust this hub's Lambda execution role (output: hub_lambda_execution_role_arn) and grant the read policy (output: target_role_policy_json)."
  type        = list(string)
  default     = []
}

variable "hub_account_name" {
  description = "Display name for the hub account in the report. Defaults to its account ID when empty."
  type        = string
  default     = ""
}

variable "schedule_expression" {
  description = "EventBridge cron expression for the weekly scan (UTC)"
  type        = string
  default     = "cron(30 3 ? * MON *)"
}

variable "force_destroy_bucket" {
  description = "Allow Terraform to delete the S3 bucket even if it contains reports."
  type        = bool
  default     = false
}


