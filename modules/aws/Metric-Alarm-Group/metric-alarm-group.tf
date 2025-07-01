# -------------------------------------------------------------------------------------
#
# Copyright (c) 2025, WSO2 LLC. (https://www.wso2.com) All Rights Reserved.
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

module "warning-metric-alarm" {
  source           = "../Metric-Alarm"
  for_each         = var.metric_alarms
  application      = var.application
  environment      = var.environment
  metric_namespace = var.metric_namespace
  project          = var.project
  region           = var.region

  alarm_actions             = each.value.priority == "critical" ? var.critical_alarm_actions : each.value.priority == "warning" ? var.warning_alarm_actions : var.info_alarm_actions
  ok_actions                = var.ok_alarm_actions
  insufficient_data_actions = var.insufficient_data_actions

  alarm_description   = "[${upper(each.value.priority)}] ${title(each.value.statistic)} ${each.value.metric_name} of ${var.resource_description} ${local.operation_description[each.value.comparison_operator]} ${each.value.threshold} in the last ${each.value.evaluation_periods} periods of ${each.value.period} seconds"
  metric_usage_prefix = lower(join("-", [var.project, var.application, var.region, var.environment, var.resource_infix, each.value.statistic, each.value.metric_name, each.value.priority]))

  comparison_operator = each.value.comparison_operator
  metric_name         = each.value.metric_name
  threshold           = each.value.threshold
  evaluation_periods  = each.value.evaluation_periods
  period              = each.value.period
  statistic           = each.value.statistic

  enabled    = var.globally_enabled && each.value.enabled ? true : false
  dimensions = var.dimensions
  tags       = var.tags
}
