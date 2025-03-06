# Global Budget for all tagged resources
resource "aws_budgets_budget" "global" {
  name          = "Choreo-global-budget"
  budget_type   = "COST"
  limit_amount  = var.cost
  limit_unit    = "USD"
  time_unit     = "MONTHLY"

  
  cost_filter {
    name   = "TagKeyValue"
    values = ["${var.tag_key}${"$"}${var.tag_value}"]
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
    notification_type         = "FORECASTED"
    subscriber_sns_topic_arns = [var.warning_sns_arn]
  }
}

# EC2 Instances Budget (configured percentage)
resource "aws_budgets_budget" "ec2" {
  name          = "Choreo-EC2-budget"
  budget_type   = "COST"
  limit_amount  = local.ec2_limit
  limit_unit    = "USD"
  time_unit     = "MONTHLY"


  cost_filter {
    name   = "TagKeyValue"
    values = ["${var.tag_key}${"$"}${var.tag_value}"]
  }

  cost_filter {
    name   = "Service"
    values = [
      "Amazon Elastic Compute Cloud - Compute",
    ]
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
    notification_type         = "FORECASTED"
    subscriber_sns_topic_arns = [var.warning_sns_arn]
  }
}

# Logs Budget (configured percentage, no tag filter)
resource "aws_budgets_budget" "logs" {
  name          = "Choreo-Logs-budget"
  budget_type   = "COST"
  limit_amount  = local.logs_limit
  limit_unit    = "USD"
  time_unit     = "MONTHLY"

  cost_filter {
    name   = "TagKeyValue"
    values = ["${var.tag_key}${"$"}${var.tag_value}"]
  }

  cost_filter {
    name   = "Service"
    values = [
      "AmazonCloudWatch",
    ]
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
    notification_type         = "FORECASTED"
    subscriber_sns_topic_arns = [var.warning_sns_arn]
  }
}

# Networking Budget (configured percentage)
resource "aws_budgets_budget" "networking" {
  name          = "Choreo-Networking-budget"
  budget_type   = "COST"
  limit_amount  = local.networking_limit
  limit_unit    = "USD"
  time_unit     = "MONTHLY"

  cost_filter {
    name   = "TagKeyValue"
    values = ["${var.tag_key}${"$"}${var.tag_value}"]
  }

  cost_filter {
    name   = "Service"
    values = [
      "AmazonVPC",
    ]
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
    notification_type         = "FORECASTED"
    subscriber_sns_topic_arns = [var.warning_sns_arn]
  }
}
