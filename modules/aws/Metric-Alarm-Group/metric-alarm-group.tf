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