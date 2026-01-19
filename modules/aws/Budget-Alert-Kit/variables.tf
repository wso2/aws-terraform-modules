# -------------------------------------------------------------------------------------
#
# Copyright (c) 2025, WSO2 LLC. (http://www.wso2.com). All Rights Reserved.
#
# This software is the property of WSO2 LLC. and its suppliers, if any.
# Dissemination of any information or reproduction of any material contained
# herein in any form is strictly forbidden, unless permitted by WSO2 expressly.
# You may not alter or remove any copyright or other notice from copies of this content.
#
# --------------------------------------------------------------------------------------

variable "cost" {
  type        = number
  description = "Total monthly budget amount in USD"
}

variable "tag_key" {
  type        = string
  description = "Tag key used to identify Choreo PDP resources"
  default     = null
}

variable "tag_value" {
  type        = string
  description = "Tag value used to identify Choreo PDP resources"
  default     = null
}

variable "critical_sns_arn" {
  type        = string
  description = "ARN for critical alerts SNS topic"
}

variable "warning_sns_arn" {
  type        = string
  description = "ARN for warning alerts SNS topic"
}

variable "per_service_budget" {
  type = map(object({
    limit          = number
    service_filter = string
  }))
  description = "Map of service names to their budget limits in USD"
  default     = {}
}

variable "include_tf_tagged_resources" {
  type        = bool
  description = "Whether to include resources tagged by Terraform in the budget calculations"
  default     = false
}

variable "email_addresses" {
  type        = list(string)
  description = "List of email addresses to receive budget notifications"
  default     = []
}

# Naming configuration variables
variable "name_prefix" {
  type        = string
  description = "Prefix for budget names (e.g., 'Asgardeo' or 'Choreo')"
  default     = "pc"
}

variable "environment" {
  type        = string
  description = "Environment name for resource naming (e.g., 'prod-001')"
  default     = ""
}

variable "region" {
  type        = string
  description = "Region code for resource naming (e.g., 'aps2')"
  default     = ""
}

variable "create_global_budget" {
  type        = bool
  description = "Whether to create the global budget. Set to false when using multiple instances of this module to avoid duplicate budgets."
  default     = true
}

variable "global_budget_name_override" {
  type        = string
  description = "Override the auto-generated global budget name. If provided, this will be used as the exact budget name."
  default     = Choreo
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to budget resources"
  default     = {}
}
