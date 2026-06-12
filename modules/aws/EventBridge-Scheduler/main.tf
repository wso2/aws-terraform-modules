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

resource "aws_scheduler_schedule" "schedule" {
  name       = join("-", [var.project, var.application, var.environment, var.region, var.schedule_name, "schedule"])
  group_name = var.group_name
  state      = var.state

  flexible_time_window {
    mode                      = var.flexible_time_window_mode
    maximum_window_in_minutes = var.flexible_time_window_mode == "FLEXIBLE" ? var.maximum_window_in_minutes : null
  }

  schedule_expression          = var.schedule_expression
  schedule_expression_timezone = var.schedule_expression_timezone

  target {
    arn      = var.target_arn
    role_arn = var.role_arn
    input    = var.input
  }
}
