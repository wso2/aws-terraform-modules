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

variable "metric_namespace" {
  description = "The namespace for the CloudWatch metric"
  type        = "string"
}
variable "metric_name" {
  description = "The name of the CloudWatch metric"
  type        = "string"
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
  type        = "string"
  default     = null
}
variable "comparison_operator" {
  description = "The comparison operator for the alarm"
  type        = "string"
}
variable "evaluation_periods" {
  description = "The number of periods over which to evaluate the alarm"
  type        = number
  default     = 1
}
variable "period" {
  description = "The period in seconds over which to evaluate the alarm"
  type        = number
  default     = 60
}
variable "threshold" {
  description = "The threshold for the alarm"
  type        = number
}
variable "alarm_description" {
  description = "The description of the alarm"
  type        = "string"
}
variable "dimensions" {
  description = "The dimensions for the metric"
  type        = map(string)
  default     = null
}
variable "statistic" {
  description = "The statistic for the metric"
  type        = "string"
  default     = null
}
variable "enabled" {
  description = "Whether the alarm should be enabled"
  type        = bool
  default     = true
}
variable "extended_statistic" {
  description = "The percentile statistic for the metric"
  type        = "string"
  default     = null
}