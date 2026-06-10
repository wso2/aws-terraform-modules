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

resource "aws_ce_anomaly_monitor" "service_monitor" {
  for_each          = var.per_service_anomaly_alerts
  name              = join("-", [var.project, var.environment, lower(each.key), "anomaly-monitor"])
  monitor_type      = "DIMENSIONAL"
  monitor_dimension = "SERVICE"
}

resource "aws_ce_anomaly_subscription" "critical" {
  for_each  = var.per_service_anomaly_alerts
  name      = join("-", [var.project, var.environment, lower(each.key), "critical-sub"])
  frequency = "IMMEDIATE"

  monitor_arn_list = [aws_ce_anomaly_monitor.service_monitor[each.key].arn]

  subscriber {
    type    = "SNS"
    address = var.critical_sns_arn
  }

  threshold_expression {
    and {
      dimension {
        key           = "ANOMALY_TOTAL_IMPACT_ABSOLUTE"
        match_options = ["GREATER_THAN_OR_EQUAL"]
        values        = [tostring(each.value.critical_absolute_threshold)]
      }
    }
    and {
      dimension {
        key           = "ANOMALY_TOTAL_IMPACT_PERCENTAGE"
        match_options = ["GREATER_THAN_OR_EQUAL"]
        values        = [tostring(each.value.critical_percentage_threshold)]
      }
    }
  }
}

resource "aws_ce_anomaly_subscription" "warning" {
  for_each  = var.per_service_anomaly_alerts
  name      = join("-", [var.project, var.environment, lower(each.key), "warning-sub"])
  frequency = "IMMEDIATE"

  monitor_arn_list = [aws_ce_anomaly_monitor.service_monitor[each.key].arn]

  subscriber {
    type    = "SNS"
    address = var.warning_sns_arn
  }

  threshold_expression {
    and {
      dimension {
        key           = "ANOMALY_TOTAL_IMPACT_ABSOLUTE"
        match_options = ["GREATER_THAN_OR_EQUAL"]
        values        = [tostring(each.value.warning_absolute_threshold)]
      }
    }
    and {
      dimension {
        key           = "ANOMALY_TOTAL_IMPACT_PERCENTAGE"
        match_options = ["GREATER_THAN_OR_EQUAL"]
        values        = [tostring(each.value.warning_percentage_threshold)]
      }
    }
  }
}
