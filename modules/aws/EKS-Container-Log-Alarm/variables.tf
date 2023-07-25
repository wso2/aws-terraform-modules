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
variable "comparison_operator" {
  description = "The comparison operator for the alarm"
  type        = string
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
  type        = string
}
variable "statistic" {
  description = "The statistic for the metric"
  type        = string
  default     = null
}
variable "enabled" {
  description = "Whether the alarm should be enabled"
  type        = bool
  default     = true
}
variable "extended_statistic" {
  description = "The percentile statistic for the metric"
  type        = string
  default     = null
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
variable "metric_namespace" {
  description = "The namespace for the CloudWatch metric"
  type        = string
}
variable "container_name" {
  description = "The name of the container"
  type        = string
}
variable "log_pattern" {
  description = "The pattern to search for in the log"
  type        = string
}
variable "cluster_name" {
  description = "The name of the cluster"
  type        = string
}
variable "log_purpose" {
  description = "The purpose of the log"
  type        = string
}
variable "pod_name" {
  description = "The name of the pod"
  type        = string
}
variable "namespace_name" {
  description = "The name of the namespace"
  type        = string
}
variable "tags" {
  description = "A mapping of tags to assign to the resource"
  type        = map(string)
  default     = {}
}