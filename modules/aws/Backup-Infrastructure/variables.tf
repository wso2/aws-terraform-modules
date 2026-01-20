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

variable "key_name" {
  description = "Name of the KMS key"
  type        = string
}

variable "key_abbreviation" {
  description = "Abbreviation for the KMS key"
  type        = string
  default     = "key"
}

variable "alias_name" {
  description = "Name of the KMS alias"
  type        = string
}

variable "alias_abbreviation" {
  description = "Abbreviation for the KMS alias"
  type        = string
  default     = "alias"
}

variable "vault_name" {
  description = "Name of the backup vault"
  type        = string
}

variable "vault_abbreviation" {
  description = "Abbreviation for the backup vault"
  type        = string
  default     = "vault"
}

variable "topic_name" {
  description = "Name of the SNS topic for backup notifications"
  type        = string
}

variable "topic_abbreviation" {
  description = "Abbreviation for the SNS topic for backup notifications"
  type        = string
  default     = "topic"
}

variable "role_name" {
  description = "Name of the IAM role for AWS Backup"
  type        = string
}

variable "role_abbreviation" {
  description = "Abbreviation for the IAM role for AWS Backup"
  type        = string
  default     = "role"
}

variable "backup_failed_alarm_name" {
  description = "Name of the backup failed alarm"
  type        = string
}

variable "backup_failed_alarm_name_abbreviation" {
  description = "Abbreviation for the backup failed alarm"
  type        = string
  default     = "backup-failed-alarm"
}

variable "restore_failed_alarm_name" {
  description = "Name of the restore failed alarm"
  type        = string
}

variable "restore_failed_alarm_name_abbreviation" {
  description = "Abbreviation for the restore failed alarm"
  type        = string
  default     = "restore-failed-alarm"
}

variable "bucket_name" {
  description = "Name of the backup bucket name"
  type        = string
}

variable "bucket_abbreviation" {
  description = "Abbreviation of the backup bucket name"
  type        = string
  default     = "bucket"
}

variable "plan_name" {
  description = "Name of the backup report plan"
  type        = string
}

variable "plan_abbreviation" {
  description = "Abbreviation for the backup report plan"
  type        = string
  default     = "plan"
}

variable "tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "description" {
  description = "Description for the KMS key"
  type        = string
}

# KMS Configuration
variable "kms_deletion_window_days" {
  description = "KMS key deletion window in days"
  type        = number
  default     = 30
}

variable "enable_kms_rotation" {
  description = "Enable automatic KMS key rotation"
  type        = bool
  default     = true
}

# Backup Vault Lock Configuration
variable "enable_backup_vault_lock" {
  description = "Enable backup vault lock configuration"
  type        = bool
  default     = false
}

variable "vault_lock_min_retention_days" {
  description = "Minimum retention days for vault lock"
  type        = number
  default     = 7
}

variable "vault_lock_max_retention_days" {
  description = "Maximum retention days for vault lock"
  type        = number
  default     = 365
}

variable "vault_lock_changeable_days" {
  description = "Number of days the vault lock can be changed"
  type        = number
  default     = 3
}

# Backup Vault Notifications
variable "backup_vault_events" {
  description = "List of backup vault events to notify on"
  type        = list(string)
  default = [
    "BACKUP_JOB_STARTED",
    "BACKUP_JOB_COMPLETED",
    "RESTORE_JOB_STARTED",
    "RESTORE_JOB_COMPLETED",
    "BACKUP_JOB_FAILED",
    "RESTORE_JOB_FAILED"
  ]
}

# CloudWatch Monitoring
variable "enable_backup_monitoring" {
  description = "Enable CloudWatch alarms for backup monitoring"
  type        = bool
  default     = true
}

# Backup Reporting
variable "enable_backup_reporting" {
  description = "Enable S3 bucket and report plan for backup compliance"
  type        = bool
  default     = false
}

variable "backup_framework_arns" {
  description = "List of AWS Backup Framework ARNs for compliance reporting"
  type        = list(string)
  default     = []
}
