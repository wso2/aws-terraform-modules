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

module "eks-metric-alert" {
  source              = "../Metric-Alarm"
  for_each            = local.eks_alerts
  enabled             = each.value.enabled
  tags                = var.default_tags
  metric_namespace    = local.eks_container_insights_metrics_namespace
  metric_name         = each.value.metric_name
  alarm_description   = "This alarm monitors VM CPU utilization in the DP E1 Cluster and triggers a warning alert"
  alarm_actions       = each.value.priority == "Critical" ? var.critical_alarm_actions : each.value.priority == "Warning" ? var.warning_alarm_actions : var.info_alarm_actions
  comparison_operator = each.value.comparison_operator
  threshold           = each.value.threshold
  metric_usage_prefix = join("-", [each.value.statistic, each.value.metric_name, lower(each.value.priority)])
  dimensions = {
    ClusterName = var.eks_cluster_name
  }
  period             = each.value.period
  evaluation_periods = each.value.evaluation_periods
  statistic          = each.value.statistic
  project            = var.project
  environment        = var.environment
  region             = var.region
  application        = var.application
}
