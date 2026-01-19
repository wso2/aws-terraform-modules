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

# KMS Key for Backup Vault Encryption
resource "aws_kms_key" "key" {
  description             = var.description
  deletion_window_in_days = var.kms_deletion_window_days
  enable_key_rotation     = var.enable_kms_rotation

  tags = merge(
    var.tags,
    {
      Name    = join("-", [var.key_name, var.key_abbreviation])
      Purpose = "Backup vault encryption"
    }
  )
}

resource "aws_kms_alias" "alias" {
  name          = join("-", [var.alias_name, var.alias_abbreviation])
  target_key_id = aws_kms_key.key.key_id
}

# Backup Vault
resource "aws_backup_vault" "vault" {
  name        = join("-", [var.vault_name, var.vault_abbreviation])
  kms_key_arn = aws_kms_key.key.arn

  tags = var.tags
}

# Backup Vault Lock (optional)
resource "aws_backup_vault_lock_configuration" "main" {
  count = var.enable_backup_vault_lock ? 1 : 0

  backup_vault_name   = aws_backup_vault.main.name
  min_retention_days  = var.vault_lock_min_retention_days
  max_retention_days  = var.vault_lock_max_retention_days
  changeable_for_days = var.vault_lock_changeable_days
}

# SNS Topic for Backup Notifications
resource "aws_sns_topic" "topic" {
  name              = join("-", [var.topic_name, var.topic_abbreviation])
  kms_master_key_id = aws_kms_key.key.id

  tags = var.tags
}

# Backup Vault Notifications
resource "aws_backup_vault_notifications" "vault" {
  backup_vault_name   = aws_backup_vault.vault.name
  sns_topic_arn       = aws_sns_topic.topic.arn
  backup_vault_events = var.backup_vault_events
}

# IAM Role for AWS Backup
resource "aws_iam_role" "role" {
  name = join("-", [var.role_name, var.role_abbreviation])

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "backup.amazonaws.com"
      }
    }]
  })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "backup" {
  role       = aws_iam_role.backup.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForBackup"
}

resource "aws_iam_role_policy_attachment" "restore" {
  role       = aws_iam_role.backup.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForRestores"
}

# CloudWatch Alarms for Backup Monitoring
resource "aws_cloudwatch_metric_alarm" "backup_job_failed" {
  count = var.enable_backup_monitoring ? 1 : 0

  alarm_name          = join("-", [var.backup_failed_alarm_name, var.backup_failed_alarm_name_abbreviation])
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "NumberOfBackupJobsFailed"
  namespace           = "AWS/Backup"
  period              = 3600 # 1 hour
  statistic           = "Sum"
  threshold           = 0
  alarm_description   = "Alert when backup jobs fail"
  treat_missing_data  = "notBreaching"
  alarm_actions       = [aws_sns_topic.backup_notifications.arn]

  dimensions = {
    BackupVaultName = aws_backup_vault.main.name
  }

  tags = var.tags
}

resource "aws_cloudwatch_metric_alarm" "restore_job_failed" {
  count = var.enable_backup_monitoring ? 1 : 0

  alarm_name          = join("-", [var.restore_failed_alarm_name, var.restore_failed_alarm_name_abbreviation])
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "NumberOfRestoreJobsFailed"
  namespace           = "AWS/Backup"
  period              = 3600
  statistic           = "Sum"
  threshold           = 0
  alarm_description   = "Alert when restore jobs fail"
  treat_missing_data  = "notBreaching"
  alarm_actions       = [aws_sns_topic.backup_notifications.arn]

  dimensions = {
    BackupVaultName = aws_backup_vault.main.name
  }

  tags = var.tags
}

# S3 Bucket for Backup Reports (optional)
resource "aws_s3_bucket" "backup_reports" {
  count = var.enable_backup_reporting ? 1 : 0

  bucket = join("-", [var.bucket_name, var.bucket_abbreviation])

  tags = var.tags
}

resource "aws_s3_bucket_versioning" "backup_reports" {
  count = var.enable_backup_reporting ? 1 : 0

  bucket = aws_s3_bucket.backup_reports[0].id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "backup_reports" {
  count = var.enable_backup_reporting ? 1 : 0

  bucket = aws_s3_bucket.backup_reports[0].id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.backup.arn
    }
  }
}

resource "aws_s3_bucket_public_access_block" "backup_reports" {
  count = var.enable_backup_reporting ? 1 : 0

  bucket = aws_s3_bucket.backup_reports[0].id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Backup Report Plan
resource "aws_backup_report_plan" "plan" {
  count = var.enable_backup_reporting ? 1 : 0

  name        = join("-", [var.plan_name, var.plan_abbreviation])
  description = "Backup compliance report for the account"

  report_delivery_channel {
    s3_bucket_name = aws_s3_bucket.backup_reports[0].id
    formats        = ["CSV", "JSON"]
  }

  report_setting {
    report_template = "BACKUP_JOB_REPORT"
    framework_arns  = var.backup_framework_arns
  }

  tags = var.tags
}
