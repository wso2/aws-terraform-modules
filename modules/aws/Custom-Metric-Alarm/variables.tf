# -------------------------------------------------------------------------------------
#
# Copyright (c) 2023, WSO2 LLC. (http://www.wso2.com). All Rights Reserved.
#
# This software is the property of WSO2 LLC. and its suppliers, if any.
# Dissemination of any information or reproduction of any material contained
# herein in any form is strictly forbidden, unless permitted by WSO2 expressly.
# You may not alter or remove any copyright or other notice from copies of this content.
#
# --------------------------------------------------------------------------------------

variable "project" {
  type        = string
  description = "Name of the project"
}
variable "environment" {
  type        = string
  description = "Name of the environment"
}
variable "region" {
  type        = string
  description = "Code of the region"
}
variable "application" {
  type        = string
  description = "Purpose of the Subnet"
}
variable "alarm_actions" {
  description = "The ARNs of the actions to take when the alarm changes state"
  type        = list(string)
}
variable "insufficient_data_actions" {
  description = "The ARNs of the actions to take when the alarm changes state into insufficient data"
  type        = list(string)
  default     = []
}
variable "ok_actions" {
  description = "The ARNs of the actions to take when the alarm changes state into OK"
  type        = list(string)
  default     = []
}
variable "unit" {
  description = "The unit for the metric"
  type        = string
  default     = null
}
variable "comparison_operator" {
  description = "The comparison operator for the alarm"
  type        = string
}
variable "evaluation_periods" {
  description = "The number of periods over which to evaluate the alarm"
  type        = number
  default     = 1
}
variable "threshold" {
  description = "The threshold for the alarm"
  type        = number
}
variable "alarm_description" {
  description = "The description of the alarm"
  type        = string
}
variable "dimensions" {
  description = "The dimensions for the metric"
  type        = map(string)
  default     = null
}
variable "enabled" {
  description = "Whether the alarm should be enabled"
  type        = bool
  default     = true
}
variable "metric_queries" {
  description = "A map of metric queries"
  type = map(object({
    id          = string
    label       = optional(string)
    account_id  = optional(string)
    expression  = optional(string)
    metric      = optional(string)
    period      = optional(number)
    return_data = optional(bool)
    metrics = optional(map(object({
      dimensions  = optional(string)
      metric_name = optional(string)
      namespace   = optional(string)
      period      = optional(number)
      stat        = optional(string)
      unit        = optional(string)
    })), {})
  }))
}
variable "metric_usage_prefix" {
  type        = string
  description = "Prefix for the metric usage"
}
