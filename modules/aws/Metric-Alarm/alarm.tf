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

resource "aws_cloudwatch_metric_alarm" "alert" {
  alarm_name          = join("-",[var.project, var.application, var.environment, var.region, var.metric_usage_prefix, "alarm"])
  alarm_description   = var.alarm_description

  metric_name         = var.metric_name
  namespace           = var.metric_namespace

  period              = var.period
  threshold           = var.threshold
  comparison_operator = var.comparison_operator
  evaluation_periods  = var.evaluation_periods
  statistic           = var.statistic
  extended_statistic  = var.extended_statistic
  unit                = var.unit

  alarm_actions             = var.alarm_actions
  ok_actions                = var.ok_actions
  insufficient_data_actions = var.insufficient_data_actions

  actions_enabled = var.enabled

  dimensions = var.dimensions
}