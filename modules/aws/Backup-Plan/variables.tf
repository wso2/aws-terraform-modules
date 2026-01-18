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

variable "backup_plan_abbreviation" {
  description = "Abbreviation for the backup plan name"
  type        = string
  default     = "backup-plan"
}

variable "backup_plan_name" {
  description = "Name of the backup plan"
  type        = string
}

variable "backup_rule_abbreviation" {
  description = "Abbreviation for the backup rule name"
  type        = string
  default     = "backup-rule"
}

variable "backup_rule_name" {
  description = "Name of the backup rule"
  type        = string
}

variable "backup_selection_abbreviation" {
  description = "Abbreviation for the backup selection name"
  type        = string
  default     = "backup-selection"
}

variable "backup_selection_name" {
  description = "Name of the backup selection"
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
