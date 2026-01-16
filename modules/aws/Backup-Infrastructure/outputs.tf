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

# KMS Outputs
output "kms_key_id" {
  description = "ID of the KMS key for backup vault encryption"
  value       = aws_kms_key.backup.key_id
}

output "kms_key_arn" {
  description = "ARN of the KMS key for backup vault encryption"
  value       = aws_kms_key.backup.arn
}

output "kms_alias_name" {
  description = "Name of the KMS key alias"
  value       = aws_kms_alias.backup.name
}

# Backup Vault Outputs
output "backup_vault_name" {
  description = "Name of the backup vault"
  value       = aws_backup_vault.main.name
}

output "backup_vault_arn" {
  description = "ARN of the backup vault"
  value       = aws_backup_vault.main.arn
}

output "backup_vault_id" {
  description = "ID of the backup vault"
  value       = aws_backup_vault.main.id
}

# SNS Outputs
output "sns_topic_arn" {
  description = "ARN of the backup notifications SNS topic"
  value       = aws_sns_topic.backup_notifications.arn
}

output "sns_topic_id" {
  description = "ID of the backup notifications SNS topic"
  value       = aws_sns_topic.backup_notifications.id
}

# IAM Outputs
output "backup_role_arn" {
  description = "ARN of the AWS Backup service IAM role"
  value       = aws_iam_role.backup.arn
}

output "backup_role_name" {
  description = "Name of the AWS Backup service IAM role"
  value       = aws_iam_role.backup.name
}

# CloudWatch Alarm Outputs
output "backup_job_failed_alarm_id" {
  description = "ID of the backup job failed alarm"
  value       = var.enable_backup_monitoring ? aws_cloudwatch_metric_alarm.backup_job_failed[0].id : null
}

output "restore_job_failed_alarm_id" {
  description = "ID of the restore job failed alarm"
  value       = var.enable_backup_monitoring ? aws_cloudwatch_metric_alarm.restore_job_failed[0].id : null
}

# S3 Bucket Outputs
output "backup_reports_bucket_id" {
  description = "ID of the backup reports S3 bucket"
  value       = var.enable_backup_reporting ? aws_s3_bucket.backup_reports[0].id : null
}

output "backup_reports_bucket_arn" {
  description = "ARN of the backup reports S3 bucket"
  value       = var.enable_backup_reporting ? aws_s3_bucket.backup_reports[0].arn : null
}

# Backup Report Plan Outputs
output "backup_report_plan_arn" {
  description = "ARN of the backup report plan"
  value       = var.enable_backup_reporting ? aws_backup_report_plan.compliance[0].arn : null
}

output "backup_report_plan_id" {
  description = "ID of the backup report plan"
  value       = var.enable_backup_reporting ? aws_backup_report_plan.compliance[0].id : null
}
