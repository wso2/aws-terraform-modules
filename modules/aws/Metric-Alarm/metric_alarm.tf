# -------------------------------------------------------------------------------------
#
# Copyright (c) 2026, WSO2 LLC. (https://www.wso2.com) All Rights Reserved.
#
# WSO2 LLC. licenses this file to you under the Apache License,
# Version 2.0 (the "License"); you may not use this file except
# in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied. See the License for the
# specific language governing permissions and limitations
# under the License.
#
# --------------------------------------------------------------------------------------

resource "aws_cloudwatch_metric_alarm" "metric_alarm" {
  alarm_name        = join("-", [var.alarm_abbreviation, var.alarm_name])
  alarm_description = var.alarm_description

  metric_name = var.metric_name
  namespace   = var.metric_namespace

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

  tags = var.tags

  lifecycle {
    ignore_changes = [
      datapoints_to_alarm
    ]
  }
}
