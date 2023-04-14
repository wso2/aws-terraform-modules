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

resource "aws_cloudwatch_metric_alarm" "metric_alarm" {
  alarm_name        = join("-", [var.project, var.application, var.environment, var.region, var.metric_usage_prefix, "alarm"])
  alarm_description = var.alarm_description

  threshold           = var.threshold
  comparison_operator = var.comparison_operator
  evaluation_periods  = var.evaluation_periods
  unit                = var.unit

  alarm_actions             = var.alarm_actions
  ok_actions                = var.ok_actions
  insufficient_data_actions = var.insufficient_data_actions

  actions_enabled = var.enabled

  dimensions = var.dimensions

  dynamic "metric_query" {
    for_each = var.metric_queries
    content {
      id          = metric_query.value.id
      expression  = metric_query.value.expression
      label       = metric_query.value.label
      account_id  = metric_query.value.account_id
      return_data = metric_query.value.return_data
      period      = metric_query.value.period

      dynamic "metric" {
        for_each = metric_query.value.metrics
        content {
          metric_name = metric.value.metric_name
          namespace   = metric.value.namespace
          dimensions  = metric.value.dimensions
          period      = metric.value.period
          stat        = metric.value.stat
          unit        = metric.value.unit
        }
      }
    }
  }
}
