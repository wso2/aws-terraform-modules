output "anomaly_monitor_arn" {
  description = "ARN of the created anomaly monitor."
  value       = aws_ce_anomaly_monitor.this.arn
}

output "anomaly_subscription_arn" {
  description = "ARN of the created anomaly subscription."
  value       = aws_ce_anomaly_subscription.this.arn
}
