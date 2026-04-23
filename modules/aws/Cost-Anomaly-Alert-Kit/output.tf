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

output "critical_monitor_arns" {
  value       = { for k, v in module.cost_anomaly_critical : k => v.anomaly_monitor_arn }
  description = "ARNs of all per-service critical anomaly monitors"
}
output "critical_subscription_arns" {
  value       = { for k, v in module.cost_anomaly_critical : k => v.anomaly_subscription_arn }
  description = "ARNs of all per-service critical anomaly subscriptions"
}
output "warning_monitor_arns" {
  value       = { for k, v in module.cost_anomaly_warning : k => v.anomaly_monitor_arn }
  description = "ARNs of all per-service warning anomaly monitors"
}
output "warning_subscription_arns" {
  value       = { for k, v in module.cost_anomaly_warning : k => v.anomaly_subscription_arn }
  description = "ARNs of all per-service warning anomaly subscriptions"
}