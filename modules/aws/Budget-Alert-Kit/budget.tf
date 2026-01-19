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

# Global Budget for all tagged resources
resource "aws_budgets_budget" "global" {
  name         = "Choreo-global-budget"
  budget_type  = "COST"
  limit_amount = var.cost
  limit_unit   = "USD"
  time_unit    = "MONTHLY"


  dynamic "cost_filter" {
    for_each = var.include_tf_tagged_resources ? [1] : []
    content {
      name   = "TagKeyValue"
      values = ["user:${var.tag_key}${"$"}${var.tag_value}"]
    }
  }

  notification {
    comparison_operator       = "GREATER_THAN"
    threshold                 = 100
    threshold_type            = "PERCENTAGE"
    notification_type         = "FORECASTED"
    subscriber_sns_topic_arns = [var.critical_sns_arn]
    subscriber_email_addresses = var.email_addresses
  }

  notification {
    comparison_operator       = "GREATER_THAN"
    threshold                 = 80
    threshold_type            = "PERCENTAGE"
    notification_type         = "FORECASTED"
    subscriber_sns_topic_arns = [var.warning_sns_arn]
    subscriber_email_addresses = var.email_addresses
  }
}

# EC2 Instances Budget (configured percentage)
resource "aws_budgets_budget" "per_service_budget" {
  for_each     = var.per_service_budget
  name         = "Choreo-${each.key}-budget"
  budget_type  = "COST"
  limit_amount = each.value.limit
  limit_unit   = "USD"
  time_unit    = "MONTHLY"


  dynamic "cost_filter" {
    for_each = var.include_tf_tagged_resources ? [1] : []
    content {
      name   = "TagKeyValue"
      values = ["user:${var.tag_key}${"$"}${var.tag_value}"]
    }
  }

  cost_filter {
    name = "Service"
    values = [
      "${each.value.service_filter}",
    ]
  }

  notification {
    comparison_operator       = "GREATER_THAN"
    threshold                 = 100
    threshold_type            = "PERCENTAGE"
    notification_type         = "FORECASTED"
    subscriber_sns_topic_arns = [var.critical_sns_arn]
    subscriber_email_addresses = var.email_addresses
  }

  notification {
    comparison_operator       = "GREATER_THAN"
    threshold                 = 80
    threshold_type            = "PERCENTAGE"
    notification_type         = "FORECASTED"
    subscriber_sns_topic_arns = [var.warning_sns_arn]
    subscriber_email_addresses = var.email_addresses
  }

}
