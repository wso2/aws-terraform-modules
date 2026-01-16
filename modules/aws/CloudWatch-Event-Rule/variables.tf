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

variable "name" {
  description = "The name of the rule"
  type        = string
}

variable "description" {
  description = "The description of the rule"
  type        = string
  default     = null
}

variable "event_pattern" {
  description = "The event pattern described as a JSON string. Either this or schedule_expression must be specified"
  type        = string
  default     = null
}

variable "schedule_expression" {
  description = "The scheduling expression (e.g., cron(0 20 * * ? *) or rate(5 minutes)). Either this or event_pattern must be specified"
  type        = string
  default     = null
}

variable "is_enabled" {
  description = "Whether the rule should be enabled"
  type        = bool
  default     = true
}

variable "role_arn" {
  description = "The Amazon Resource Name (ARN) associated with the role that is used for target invocation"
  type        = string
  default     = null
}

variable "tags" {
  description = "A map of tags to assign to the resource"
  type        = map(string)
  default     = {}
}
