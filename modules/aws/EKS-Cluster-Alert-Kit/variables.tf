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

variable "application" {
  type        = string
  description = "Purpose of the Monitors"
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
variable "default_tags" {
    type        = map(string)
    description = "Default tags to be applied to resources"
}
variable "eks_cluster_name" {
    type        = string
    description = "Name of the EKS cluster"
}
variable "critical_alarm_actions" {
    type        = list(string)
    description = "The ARNs of the actions to take when the alarm changes state to critical"
    default     = []
}
variable "warning_alarm_actions" {
    type        = list(string)
    description = "The ARNs of the actions to take when the alarm changes state to warning"
    default     = []
}
variable "info_alarm_actions" {
    type        = list(string)
    description = "The ARNs of the actions to take when the alarm changes state to info"
    default     = []
}
variable "max_node_count" {
    type        = number
    description = "Maximum number of nodes in the EKS cluster"
}
variable "eks_alerts" {
  type = map(object({
    threshold = number
    evaluation_periods = number
    period = number
    statistic = string
    comparison_operator = string
    metric_name = string
    priority = string
    enabled = optional(bool,true)
  }))
  default = {
    "avg-cpu-utilization-warning" = {
      threshold = 80
      evaluation_periods = 1
      period = 60
      statistic = "Average"
      comparison_operator = "GreaterThanOrEqualToThreshold"
      metric_name = "node_cpu_utilization"
      priority = "Warning"
    },
    "avg-cpu-utilization-critical" = {
      threshold = 90
      evaluation_periods = 1
      period = 60
      statistic = "Average"
      comparison_operator = "GreaterThanOrEqualToThreshold"
      metric_name = "node_cpu_utilization"
      priority = "Critical"
    },
    "avg-memory-utilization-warning" = {
      threshold = 80
      evaluation_periods = 1
      period = 60
      statistic = "Average"
      comparison_operator = "GreaterThanOrEqualToThreshold"
      metric_name = "node_memory_utilization"
      priority = "Warning"
    },
    "avg-memory-utilization-critical" = {
      threshold = 90
      evaluation_periods = 1
      period = 60
      statistic = "Average"
      comparison_operator = "GreaterThanOrEqualToThreshold"
      metric_name = "node_memory_utilization"
      priority = "Critical"
    }
    "avg-fs-utilization-warning" = {
      threshold = 80
      evaluation_periods = 1
      period = 60
      statistic = "Average"
      comparison_operator = "GreaterThanOrEqualToThreshold"
      metric_name = "node_filesystem_utilization"
      priority = "Warning"
    },
    "avg-fs-utilization-critical" = {
      threshold = 90
      evaluation_periods = 1
      period = 60
      statistic = "Average"
      comparison_operator = "GreaterThanOrEqualToThreshold"
      metric_name = "node_filesystem_utilization"
      priority = "Critical"
    },
    "max-cpu-utilization-warning" = {
      threshold = 80
      evaluation_periods = 1
      period = 60
      statistic = "Maximum"
      comparison_operator = "GreaterThanOrEqualToThreshold"
      metric_name = "node_cpu_utilization"
      priority = "Warning"
    },
    "max-cpu-utilization-critical" = {
      threshold = 90
      evaluation_periods = 1
      period = 60
      statistic = "Maximum"
      comparison_operator = "GreaterThanOrEqualToThreshold"
      metric_name = "node_cpu_utilization"
      priority = "Critical"
    },
    "max-memory-utilization-warning" = {
      threshold = 80
      evaluation_periods = 1
      period = 60
      statistic = "Maximum"
      comparison_operator = "GreaterThanOrEqualToThreshold"
      metric_name = "node_memory_utilization"
      priority = "Warning"
    },
    "max-memory-utilization-critical" = {
      threshold = 90
      evaluation_periods = 1
      period = 60
      statistic = "Maximum"
      comparison_operator = "GreaterThanOrEqualToThreshold"
      metric_name = "node_memory_utilization"
      priority = "Critical"
    },
    "max-fs-utilization-warning" = {
      threshold = 80
      evaluation_periods = 1
      period = 60
      statistic = "Maximum"
      comparison_operator = "GreaterThanOrEqualToThreshold"
      metric_name = "node_filesystem_utilization"
      priority = "Warning"
    },
    "max-fs-utilization-critical" = {
      threshold = 90
      evaluation_periods = 1
      period = 60
      statistic = "Maximum"
      comparison_operator = "GreaterThanOrEqualToThreshold"
      metric_name = "node_filesystem_utilization"
      priority = "Critical"
    },
    "node-failed-count-warning" = {
      threshold = 1
      evaluation_periods = 1
      period = 60
      statistic = "Sum"
      comparison_operator = "GreaterThanOrEqualToThreshold"
      metric_name = "node_failed_count"
      priority = "Warning"
    },
    "node-failed-count-critical" = {
      threshold = 2
      evaluation_periods = 1
      period = 60
      statistic = "Sum"
      comparison_operator = "GreaterThanOrEqualToThreshold"
      metric_name = "node_failed_count"
      priority = "Critical"
    },
  }
}
