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

# An alarm whose state is a rule over other alarms, for example
# ALARM("<arn-a>") AND ALARM("<arn-b>"). Its child alarms usually notify nobody.
resource "aws_cloudwatch_composite_alarm" "composite_alarm" {
  alarm_name                = var.name
  alarm_description         = var.description
  alarm_rule                = var.alarm_rule
  actions_enabled           = var.actions_enabled
  alarm_actions             = var.alarm_actions
  ok_actions                = var.ok_actions
  insufficient_data_actions = var.insufficient_data_actions

  dynamic "actions_suppressor" {
    for_each = var.actions_suppressor != null ? [var.actions_suppressor] : []
    content {
      alarm            = actions_suppressor.value.alarm
      extension_period = actions_suppressor.value.extension_period
      wait_period      = actions_suppressor.value.wait_period
    }
  }

  tags = var.tags
}
