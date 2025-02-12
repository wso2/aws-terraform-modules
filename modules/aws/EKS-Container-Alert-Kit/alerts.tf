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

module "container-log-alerts" {
  source       = "../Custom-AKS-Application-Log-Alarm"
  for_each     = var.container_log_alerts
  cluster_name = var.cluster_name
  namespace    = var.namespace
  application  = var.application
  environment  = var.environment
  pod_name     = var.pod_name
  project      = var.project
  region       = var.region

  # If priority is Critical then use critical_alarm_actions if Warning then use warning alarm actions if Info use info alarm actions
  alarm_actions             = each.value.priority == "Critical" ? var.critical_alarm_actions : each.value.priority == "Warning" ? var.warning_alarm_actions : var.info_alarm_actions
  ok_actions                = var.ok_actions
  insufficient_data_actions = var.insufficient_data_actions
  log_alarm_description     = "[${upper(each.value.priority)}] Number of \"${each.value.log_entry}\" log entries ${each.value.comparison_operator} ${each.value.threshold} in logs of ${each.value.k8s_container_name}  in pod ${var.pod_name} in namespace ${var.namespace} in cluster ${var.cluster_name} within last ${each.value.evaluation_periods} ${each.value.time_window} second periods"
  comparison_operator       = each.value.comparison_operator
  k8s_container_name        = each.value.k8s_container_name
  evaluation_periods        = each.value.evaluation_periods
  time_window               = each.value.time_window
  enabled                   = each.value.enabled
  log_entry                 = each.value.log_entry
  error_log_summary         = join("-", [var.namespace, var.pod_name, each.value.k8s_container_name, each.value.log_summary])
  threshold                 = each.value.threshold

  tags = var.default_tags
}

module "container-pod-metric-alerts" {
  source   = "../Metric-Alarm"
  for_each = var.metric_pod_alerts

  alarm_actions             = each.value.priority == "Critical" ? var.critical_alarm_actions : each.value.priority == "Warning" ? var.warning_alarm_actions : var.info_alarm_actions
  alarm_description         = "[${upper(each.value.priority)}] ${each.value.statistic} ${replace(each.value.metric_name,"_"," ")} of the pod ${var.pod_name} in namespace ${var.namespace} in cluster ${var.cluster_name} ${each.value.comparison_operator} ${each.value.threshold} within last ${each.value.evaluation_periods} ${each.value.period} second periods"
  application               = var.application
  tags                      = var.default_tags
  project                   = var.project
  region                    = var.region
  metric_namespace          = local.eks_container_insights_metrics_namespace
  ok_actions                = var.ok_actions
  insufficient_data_actions = var.insufficient_data_actions
  environment               = var.environment

  comparison_operator = each.value.comparison_operator
  metric_name         = each.value.metric_name
  metric_usage_prefix = join("-", [var.namespace, var.pod_name, each.value.statistic, each.value.metric_name, lower(each.value.priority)])
  threshold           = each.value.threshold
  enabled             = each.value.enabled
  evaluation_periods  = each.value.evaluation_periods
  period              = each.value.period
  statistic           = each.value.statistic

  dimensions = {
    ClusterName = var.cluster_name
    PodName     = var.pod_name
    Namespace   = var.namespace
  }
}

module "container-service-metric-alerts" {
  source   = "../Metric-Alarm"
  for_each = var.metric_service_alerts

  alarm_actions             = each.value.priority == "Critical" ? var.critical_alarm_actions : each.value.priority == "Warning" ? var.warning_alarm_actions : var.info_alarm_actions
  alarm_description         = "[${upper(each.value.priority)}] ${each.value.statistic} ${replace(each.value.metric_name,"_"," ")} of the service ${var.service_name} in namespace ${var.namespace} in cluster ${var.cluster_name} ${each.value.comparison_operator} ${each.value.threshold} within last ${each.value.evaluation_periods} ${each.value.period} second periods"
  application               = var.application
  tags                      = var.default_tags
  project                   = var.project
  region                    = var.region
  metric_namespace          = local.eks_container_insights_metrics_namespace
  ok_actions                = var.ok_actions
  insufficient_data_actions = var.insufficient_data_actions
  environment               = var.environment

  comparison_operator = each.value.comparison_operator
  metric_name         = each.value.metric_name
  metric_usage_prefix = join("-", [var.namespace, var.pod_name, each.value.statistic, each.value.metric_name, lower(each.value.priority)])
  threshold           = each.value.threshold
  enabled             = each.value.enabled
  evaluation_periods  = each.value.evaluation_periods
  period              = each.value.period
  statistic           = each.value.statistic

  dimensions = {
    ClusterName = var.cluster_name
    Service = var.service_name
    Namespace   = var.namespace
  }
}


