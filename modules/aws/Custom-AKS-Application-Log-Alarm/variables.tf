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

variable "k8s_container_name" {
  description = "Name of the container"
  type        = string
}
variable "cluster_name" {
  description = "Name of the cluster"
  type        = string
}
variable "error_log_summary" {
  description = "Error log summary"
  type        = string
}
variable "namespace" {
  description = "Namespace which contains the container"
  type        = string
}
variable "log_entry" {
  description = "Log entry to be detected"
  type        = string
}
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
variable "log_alarm_description" {
  description = "Description of the alarm"
  type        = string
}
variable "threshold" {
  description = "Threshold for the alarm"
  type        = number
}
variable "comparison_operator" {
  description = "Comparison operator for the alarm"
  type        = string
}
variable "evaluation_periods" {
  description = "How often the alarm needs to be evaluated"
  type        = number
}
variable "time_window" {
  description = "Time window for the alarm"
  type        = number
}
variable "enabled" {
  description = "Whether the alarm should be enabled"
  type        = bool
  default     = true
}
variable "tags" {
  description = "Tags to be added to the alarm"
  type        = map(string)
  default     = {}
}