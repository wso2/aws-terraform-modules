# -------------------------------------------------------------------------------------
#
# Copyright (c) 2025, WSO2 LLC. (http://www.wso2.com). All Rights Reserved.
#
# This software is the property of WSO2 LLC. and its suppliers, if any.
# Dissemination of any information or reproduction of any material contained
# herein in any form is strictly forbidden, unless permitted by WSO2 expressly.
# You may not alter or remove any copyright or other notice from copies of this content.
#
# --------------------------------------------------------------------------------------

locals {
  # Build name suffix from environment and region if provided
  name_suffix = join("-", compact([var.environment, var.region]))

  # Global budget name: use override if provided, otherwise construct from prefix
  global_budget_name = coalesce(
    var.global_budget_name_override,
    local.name_suffix != "" ? "${var.name_prefix}-${local.name_suffix}-global-budget" : "${var.name_prefix}-global-budget"
  )

  # Per-service budget name prefix
  per_service_name_prefix = local.name_suffix != "" ? "${var.name_prefix}-${local.name_suffix}" : var.name_prefix
}

resource "aws_budgets_budget" "global" {
  count = var.create_global_budget ? 1 : 0

  name         = local.global_budget_name
  budget_type  = "COST"
  limit_amount = var.cost
  limit_unit   = "USD"
  time_unit    = "MONTHLY"

  dynamic "cost_filter" {
    for_each = var.tag_key != null && var.tag_value != null ? [1] : []
    content {
      name   = "TagKeyValue"
      values = ["user:${var.tag_key}$${var.tag_value}"]
    }
  }

  notification {
    comparison_operator       = "GREATER_THAN"
    threshold                 = 100
    threshold_type            = "PERCENTAGE"
    notification_type         = "FORECASTED"
    subscriber_sns_topic_arns = [var.critical_sns_arn]
  }

  notification {
    comparison_operator       = "GREATER_THAN"
    threshold                 = 80
    threshold_type            = "PERCENTAGE"
    notification_type         = "ACTUAL"
    subscriber_sns_topic_arns = [var.warning_sns_arn]
  }

  tags = var.tags
}

resource "aws_budgets_budget" "per_service_budget" {
  for_each = var.per_service_budget

  name         = "${local.per_service_name_prefix}-${each.key}-budget"
  budget_type  = "COST"
  limit_amount = each.value.limit
  limit_unit   = "USD"
  time_unit    = "MONTHLY"

  cost_filter {
    name   = "Service"
    values = [each.value.service_filter]
  }

  dynamic "cost_filter" {
    for_each = var.tag_key != null && var.tag_value != null ? [1] : []
    content {
      name   = "TagKeyValue"
      values = ["user:${var.tag_key}$${var.tag_value}"]
    }
  }

  notification {
    comparison_operator       = "GREATER_THAN"
    threshold                 = 100
    threshold_type            = "PERCENTAGE"
    notification_type         = "FORECASTED"
    subscriber_sns_topic_arns = [var.critical_sns_arn]
  }

  notification {
    comparison_operator       = "GREATER_THAN"
    threshold                 = 80
    threshold_type            = "PERCENTAGE"
    notification_type         = "ACTUAL"
    subscriber_sns_topic_arns = [var.warning_sns_arn]
  }

  tags = var.tags
}
