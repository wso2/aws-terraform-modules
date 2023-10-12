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

resource "aws_cloudwatch_log_metric_filter" "log_metric_filter" {
  name = join("-", [local.log_usage_prefix, "filter"])
  #pattern        = join("", ["{ ($.container_name = \"*" , var.container_name, "*\") && ($.log = \"*" , var.log_pattern, "*\") }"])
  pattern        = "{ ($.kubernetes.container_name = \"${var.container_name}\") && ($.log = \"*${var.log_pattern}*\") } && ($.kubernetes.namespace_name = \"${var.namespace_name}\") && ($.kubernetes.pod_name = \"*${var.pod_name}*\")"
  log_group_name = "/aws/containerinsights/${var.cluster_name}/application"

  metric_transformation {
    name      = join("-", [var.application, local.log_usage_prefix, "count"])
    namespace = var.metric_namespace
    value     = "1"
  }
}

resource "aws_cloudwatch_metric_alarm" "metric_alarm" {
  alarm_name = join("-", [var.project, var.application, var.environment, var.region, local.log_usage_prefix, "alarm"])

  metric_name = join("-", [var.application, local.log_usage_prefix, "count"])
  namespace   = var.metric_namespace

  alarm_description   = var.alarm_description
  comparison_operator = var.comparison_operator
  evaluation_periods  = var.evaluation_periods
  period              = var.period
  statistic           = var.statistic
  extended_statistic  = var.extended_statistic
  threshold           = var.threshold

  actions_enabled = var.enabled

  alarm_actions             = var.alarm_actions
  ok_actions                = var.ok_actions
  insufficient_data_actions = var.insufficient_data_actions

  tags = var.tags
}
