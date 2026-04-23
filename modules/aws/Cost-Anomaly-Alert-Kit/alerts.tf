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

module "cost_anomaly_critical" {
  source   = "../Cost-Anomaly-Detection"
  for_each = var.per_service_anomaly_alerts

  monitor_name                      = join("-", [var.project, var.environment, lower(each.key), "critical"])
  monitor_abbreviation              = "anomaly-monitor"
  monitor_type                      = "DIMENSIONAL"
  monitor_dimension                 = "SERVICE"
  monitor_subscription_name         = join("-", [var.project, var.environment, lower(each.key), "critical"])
  monitor_subscription_abbreviation = "sub"
  frequency                         = "IMMEDIATE"
  subscriber_type                   = "SNS"
  subscriber_address                = var.critical_sns_arn
  absolute_threshold                = each.value.critical_absolute_threshold
  percentage_threshold              = each.value.critical_percentage_threshold
}

module "cost_anomaly_warning" {
  source   = "../Cost-Anomaly-Detection"
  for_each = var.per_service_anomaly_alerts

  monitor_name                      = join("-", [var.project, var.environment, lower(each.key), "warning"])
  monitor_abbreviation              = "anomaly-monitor"
  monitor_type                      = "DIMENSIONAL"
  monitor_dimension                 = "SERVICE"
  monitor_subscription_name         = join("-", [var.project, var.environment, lower(each.key), "warning"])
  monitor_subscription_abbreviation = "sub"
  frequency                         = "DAILY"
  subscriber_type                   = "SNS"
  subscriber_address                = var.warning_sns_arn
  absolute_threshold                = each.value.warning_absolute_threshold
  percentage_threshold              = each.value.warning_percentage_threshold
}