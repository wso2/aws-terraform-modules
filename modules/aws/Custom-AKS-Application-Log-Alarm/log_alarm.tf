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

# Resource block for metric filter
resource "aws_cloudwatch_log_metric_filter" "aks_application_log_metric_filter" {
  name           = join("-", [var.project, var.application, var.environment, var.region, var.error_log_summary, "metric-filter"])
  pattern        = "{ ($.kubernetes.container_name = \"${var.k8s_container_name}\") && ($.kubernetes.namespace_name = \"${var.namespace}\") && ($.log = \"*${var.log_entry}*\") } "
  log_group_name = "/aws/containerinsights/${var.cluster_name}/application"

  metric_transformation {
    name      = "${var.cluster_name}-${var.error_log_summary}"
    namespace = "K8SApplicationLogsCount"
    value     = "1"
  }
}

# Log entry
resource "aws_cloudwatch_metric_alarm" "metric_alarm" {
  alarm_name        = join("-", [var.project, var.application, var.environment, var.region, var.error_log_summary, "log-alarn"])
  alarm_description = var.log_alarm_description

  threshold           = var.threshold
  comparison_operator = var.comparison_operator
  evaluation_periods  = var.evaluation_periods
  unit                = "Count"

  alarm_actions             = var.alarm_actions
  ok_actions                = var.ok_actions
  insufficient_data_actions = var.insufficient_data_actions

  actions_enabled = var.enabled

  metric_name = "${var.cluster_name}-${var.error_log_summary}"
  namespace   = "K8SApplicationLogsCount"
  period    = var.time_window
  statistic = "Sum"

}
