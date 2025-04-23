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
variable "pod_name" {
  type        = string
  description = "Name of the pod"
}
variable "service_name" {
  type        = string
  description = "Name of the service that exposes the pod"
}
variable "namespace" {
  type        = string
  description = "Namespace which contains the container"
}
variable "cluster_name" {
  type        = string
  description = "Name of the cluster"
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
variable "container_log_alerts" {
  type = map(object({
    priority            = string
    comparison_operator = string
    evaluation_periods  = number
    time_window         = number
    enabled             = optional(bool, true)
    log_entry           = string
    log_summary         = string
    threshold           = number
    k8s_container_name  = string
  }))
  description = "Container log alerts"
  default     = {}
}
variable "metric_pod_alerts" {
  type = map(object({
    priority            = string
    comparison_operator = string
    threshold           = number
    enabled             = optional(bool, true)
    metric_name         = string
    statistic           = string
    evaluation_periods  = number
    period              = number
  }))
  description = "Metric alerts"
  default = {
    avg_cpu_utilization_critical = {
      priority            = "Critical"
      comparison_operator = "GreaterThanOrEqualToThreshold"
      threshold           = 90
      metric_name         = "pod_cpu_utilization_over_pod_limit"
      statistic           = "Average"
      evaluation_periods  = 1
      period              = 60
    },
    avg_cpu_utilization_warning = {
      priority            = "Warning"
      comparison_operator = "GreaterThanOrEqualToThreshold"
      threshold           = 80
      metric_name         = "pod_cpu_utilization_over_pod_limit"
      statistic           = "Average"
      evaluation_periods  = 1
      period              = 60
    },
    avg_memory_utilization_critical = {
      priority            = "Critical"
      comparison_operator = "GreaterThanOrEqualToThreshold"
      threshold           = 90
      metric_name         = "pod_memory_utilization_over_pod_limit"
      statistic           = "Average"
      evaluation_periods  = 1
      period              = 60
    },
    avg_memory_utilization_warning = {
      priority            = "Warning"
      comparison_operator = "GreaterThanOrEqualToThreshold"
      threshold           = 80
      metric_name         = "pod_memory_utilization_over_pod_limit"
      statistic           = "Average"
      evaluation_periods  = 1
      period              = 60
    },
    max_cpu_utilization_critical = {
      priority            = "Critical"
      comparison_operator = "GreaterThanOrEqualToThreshold"
      threshold           = 90
      metric_name         = "pod_cpu_utilization_over_pod_limit"
      statistic           = "Maximum"
      evaluation_periods  = 1
      period              = 60
    },
    max_cpu_utilization_warning = {
      priority            = "Warning"
      comparison_operator = "GreaterThanOrEqualToThreshold"
      threshold           = 80
      metric_name         = "pod_cpu_utilization_over_pod_limit"
      statistic           = "Maximum"
      evaluation_periods  = 1
      period              = 60
    },
    max_memory_utilization_critical = {
      priority            = "Critical"
      comparison_operator = "GreaterThanOrEqualToThreshold"
      threshold           = 90
      metric_name         = "pod_memory_utilization_over_pod_limit"
      statistic           = "Maximum"
      evaluation_periods  = 1
      period              = 60
    },
    max_memory_utilization_warning = {
      priority            = "Warning"
      comparison_operator = "GreaterThanOrEqualToThreshold"
      threshold           = 80
      metric_name         = "pod_memory_utilization_over_pod_limit"
      statistic           = "Maximum"
      evaluation_periods  = 1
      period              = 60
    }
    container_restarts_warning = {
      priority            = "Warning"
      comparison_operator = "GreaterThanOrEqualToThreshold"
      threshold           = 1
      metric_name         = "pod_number_of_container_restart"
      statistic           = "Sum"
      evaluation_periods  = 1
      period              = 60
    }
    container_restarts_critical = {
      priority            = "Critical"
      comparison_operator = "GreaterThanOrEqualToThreshold"
      threshold           = 5
      metric_name         = "pod_number_of_container_restart"
      statistic           = "Sum"
      evaluation_periods  = 1
      period              = 60
    }
  }
}
variable "metric_service_alerts" {
  type = map(object({
    priority            = string
    comparison_operator = string
    threshold           = number
    enabled             = optional(bool, true)
    metric_name         = string
    statistic           = string
    evaluation_periods  = number
    period              = number
  }))
  description = "Metric alerts"
  default = {
    service_number_of_running_pods_warning = {
      priority            = "Warning"
      comparison_operator = "LessThanThreshold"
      threshold           = 2
      metric_name         = "service_number_of_running_pods"
      statistic           = "Sum"
      evaluation_periods  = 1
      period              = 60
    },
    service_number_of_running_pods_critical = {
      priority            = "Critical"
      comparison_operator = "LessThanThreshold"
      threshold           = 1
      metric_name         = "service_number_of_running_pods"
      statistic           = "Sum"
      evaluation_periods  = 1
      period              = 60
    }
  }
}
variable "ok_actions" {
  type        = list(string)
  description = "The ARNs of the actions to take when the alarm changes state to OK"
  default     = []
}
variable "insufficient_data_actions" {
  type        = list(string)
  description = "The ARNs of the actions to take when the alarm changes state to insufficient data"
  default     = []
}