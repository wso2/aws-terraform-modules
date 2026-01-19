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

resource "aws_ce_anomaly_monitor" "anomaly_monitor" {
  name              = join("-", [var.monitor_name, var.monitor_abbrevaition])
  monitor_type      = var.monitor_type
  monitor_dimension = var.monitor_dimension
}

resource "aws_ce_anomaly_subscription" "anomaly_subscription" {
  name             = join("-", [var.monitor_subscription_name, var.monitor_subscription_abbreviation])
  monitor_arn_list = [aws_ce_anomaly_monitor.anomaly_monitor.arn]
  frequency        = var.frequency

  threshold_expression {
    dimension {
      key           = var.threshold_key
      values        = [tostring(var.threshold)]
      match_options = var.threshold_match_options
    }
  }

  subscriber {
    type    = var.subscriber_type
    address = var.subscriber_address
  }
}
