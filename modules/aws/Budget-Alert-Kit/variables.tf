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
