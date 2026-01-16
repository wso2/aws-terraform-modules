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
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Environment name (e.g., prod, dev, staging)"
  type        = string
}

variable "region" {
  description = "AWS region"
  type        = string
}

variable "service_name" {
  description = "Service name for the backup plan (e.g., rds, efs, eks)"
  type        = string
}

variable "backup_vault_name" {
  description = "Name of the backup vault to use"
  type        = string
}

variable "backup_iam_role_arn" {
  description = "ARN of the IAM role for AWS Backup"
  type        = string
}

variable "backup_rules" {
  description = "List of backup rules with flexible schedule configuration"
  type = list(object({
    name              = string           # Rule name (e.g., hourly, daily, weekly, monthly)
    schedule          = string           # Cron expression for backup schedule
    retention_days    = number           # Number of days to retain backups
    cold_storage_days = optional(number) # Days after which to move to cold storage (null for no cold storage)
    start_window      = optional(number) # Backup start window in minutes (default: 60)
    completion_window = optional(number) # Backup completion window in minutes (default: 120)
    copy_actions = optional(list(object({
      destination_vault_arn = string           # ARN of destination vault for cross-region copy
      retention_days        = optional(number) # Retention in destination (default: same as source)
      cold_storage_days     = optional(number) # Cold storage in destination (default: null)
    })))
  }))

  validation {
    condition     = length(var.backup_rules) > 0
    error_message = "At least one backup rule must be defined."
  }

  validation {
    condition     = alltrue([for rule in var.backup_rules : rule.retention_days > 0])
    error_message = "Retention days must be greater than 0 for all rules."
  }

  validation {
    condition = alltrue([
      for rule in var.backup_rules :
      try(rule.cold_storage_days == null, true) || try(rule.cold_storage_days < rule.retention_days, false)
    ])
    error_message = "cold_storage_days must be less than retention_days when specified."
  }
}

variable "selection_tag_key" {
  description = "Tag key for resource selection (e.g., BackupPolicy)"
  type        = string
  default     = "BackupPolicy"
}

variable "selection_tag_value" {
  description = "Tag value for resource selection (e.g., RDS, EFS, EKS)"
  type        = string
}

variable "tags" {
  description = "A map of tags to assign to resources"
  type        = map(string)
  default     = {}
}
