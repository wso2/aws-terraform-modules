# AWS Cost Anomaly Detection Terraform Module

resource "aws_ce_anomaly_monitor" "this" {
  name              = var.monitor_name
  monitor_type      = var.monitor_type
  monitor_dimension = var.monitor_dimension
}

resource "aws_ce_anomaly_subscription" "this" {
  name             = var.subscription_name
  monitor_arn_list = [aws_ce_anomaly_monitor.this.arn]
  threshold        = var.threshold
  frequency        = var.frequency
  subscribers {
    type    = var.subscriber_type
    address = var.subscriber_address
  }
}
