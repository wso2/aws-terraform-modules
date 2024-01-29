# -------------------------------------------------------------------------------------
#
# Copyright (c) 2023, WSO2 LLC. (http://www.wso2.com). All Rights Reserved.
#
# This software is the property of WSO2 LLC. and its suppliers, if any.
# Dissemination of any information or reproduction of any material contained
# herein in any form is strictly forbidden, unless permitted by WSO2 expressly.
# You may not alter or remove any copyright or other notice from copies of this content.
#
# --------------------------------------------------------------------------------------

variable "project" {
  type        = string
  description = "The name of the project"
}
variable "environment" {
  type        = string
  description = "The name of the environment"
}
variable "region" {
  type        = string
  description = "The name of the region"
}
variable "application" {
  type        = string
  description = "The name of the application"
}
variable "backup_plan_name" {
  description = "Name of the backup plan"
  type        = string
}
variable "rule_name" {
  description = "Name of the backup rule"
  type        = string
}
variable "vault_name" {
  description = "Name of the vault"
  type        = string
}
variable "schedule" {
  description = "Schedule of the backup"
  type        = string
}
variable "enable_continuous_backup" {
  description = "Enable continuous backup"
  type        = bool
}
variable "start_window" {
  description = "Start window of the backup"
  type        = string
  default     = null
}
variable "completion_window" {
  description = "Completion window of the backup"
  type        = string
  default     = null
}
variable "cold_storage_after" {
  description = "Cold storage after of the backup"
  type        = string
  default     = null
}
variable "delete_after" {
  description = "Delete after of the backup"
  type        = string
}
variable "opt_in_to_archive_for_supported_resource" {
  description = "Opt in to archive for supported resource"
  type        = bool
  default     = false
}
variable "backup_resources" {
  description = "Backup resources"
  type        = list(string)
}
variable "backup_selection_name" {
  description = "Backup selection name"
  type        = string
}