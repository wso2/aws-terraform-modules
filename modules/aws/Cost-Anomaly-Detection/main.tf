# AWS Cost Anomaly Detection Terraform Module

resource "aws_ce_anomaly_monitor" "this" {
  name              = var.monitor_name
  monitor_type      = var.monitor_type
  monitor_dimension = var.monitor_dimension
}

resource "aws_ce_anomaly_subscription" "this" {
  name             = var.subscription_name
  monitor_arn_list = [aws_ce_anomaly_monitor.this.arn]
  frequency        = var.frequency

  threshold_expression {
    dimension {
      key           = "ANOMALY_TOTAL_IMPACT_ABSOLUTE"
      values        = [tostring(var.threshold)]
      match_options = ["GREATER_THAN_OR_EQUAL"]
    }
  }

  subscriber {
    type    = var.subscriber_type
    address = var.subscriber_address
  }
}
