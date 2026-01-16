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

variable "project" {
  description = "Project name for resource naming"
  type        = string
}

variable "environment" {
  description = "Environment name (prod, staging, dev)"
  type        = string
}

variable "region" {
  description = "AWS region for resource deployment"
  type        = string
}

variable "tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
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

variable "alarm_actions" {
  description = "List of ARNs to notify when alarms trigger (SNS topics, etc.)"
  type        = list(string)
  default     = []
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
