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

# KMS Outputs
output "kms_key_id" {
  description = "ID of the KMS key for backup vault encryption"
  value       = aws_kms_key.key.key_id
}

output "kms_key_arn" {
  description = "ARN of the KMS key for backup vault encryption"
  value       = aws_kms_key.key.arn
}

output "kms_alias_name" {
  description = "Name of the KMS key alias"
  value       = aws_kms_alias.alias.name
}

# Backup Vault Outputs
output "backup_vault_name" {
  description = "Name of the backup vault"
  value       = aws_backup_vault.vault.name
}

output "backup_vault_arn" {
  description = "ARN of the backup vault"
  value       = aws_backup_vault.vault.arn
}

output "backup_vault_id" {
  description = "ID of the backup vault"
  value       = aws_backup_vault.vault.id
}

# SNS Outputs
output "sns_topic_arn" {
  description = "ARN of the backup notifications SNS topic"
  value       = aws_sns_topic.topic.arn
}

output "sns_topic_id" {
  description = "ID of the backup notifications SNS topic"
  value       = aws_sns_topic.topic.id
}

# IAM Outputs
output "backup_role_arn" {
  description = "ARN of the AWS Backup service IAM role"
  value       = aws_iam_role.role.arn
}

output "backup_role_name" {
  description = "Name of the AWS Backup service IAM role"
  value       = aws_iam_role.role.name
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
  value       = var.enable_backup_reporting ? aws_backup_report_plan.plan[0].arn : null
}

output "backup_report_plan_id" {
  description = "ID of the backup report plan"
  value       = var.enable_backup_reporting ? aws_backup_report_plan.plan[0].id : null
}
