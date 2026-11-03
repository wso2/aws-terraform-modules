# -------------------------------------------------------------------------------------
#
# Copyright (c) 2026, WSO2 LLC. (http://www.wso2.com). All Rights Reserved.
#
# This software is the property of WSO2 LLC. and its suppliers, if any.
# Dissemination of any information or reproduction of any material contained
# herein in any form is strictly forbidden, unless permitted by WSO2 expressly.
# You may not alter or remove any copyright or other notice from copies of this content.
#
# --------------------------------------------------------------------------------------

variable "project" {
  description = "Name of the project"
  type        = string
}

variable "application" {
  description = "Purpose of the DB Cluster"
  type        = string
}

variable "environment" {
  description = "Name of the environment"
  type        = string
}

variable "region" {
  description = "Code of the region"
  type        = string
}

variable "global_cluster_identifier" {
  description = "Identifier of the Aurora Global Database to join"
  type        = string
}

variable "engine" {
  description = "Engine of the global database"
  type        = string
}

variable "engine_version" {
  description = "Engine version of the global database"
  type        = string
}

variable "db_subnet_group_name" {
  description = "DB subnet group in the secondary region"
  type        = string
}

variable "vpc_security_group_ids" {
  description = "Security groups for the DB Cluster"
  type        = list(string)
  default     = []
}

variable "database_port" {
  description = "Port of the DB Cluster"
  type        = number
  default     = null
}

variable "kms_key_id" {
  description = "ARN of the KMS key in the secondary region used for storage encryption"
  type        = string
}

variable "iam_database_authentication_enabled" {
  description = "Enable IAM database authentication"
  type        = bool
  default     = false
}

variable "enabled_cloudwatch_log_exports" {
  description = "Log types to export to CloudWatch"
  type        = list(string)
  default     = []
}

variable "engine_lifecycle_support" {
  description = "Engine lifecycle support setting"
  type        = string
  default     = null
}

variable "skip_final_snapshot" {
  description = "Skip the final snapshot on deletion"
  type        = bool
  default     = false
}

variable "deletion_protection" {
  description = "Enable deletion protection for the DB Cluster"
  type        = bool
  default     = true
}

variable "min_capacity" {
  description = "Serverless v2 minimum capacity"
  type        = number
  default     = 0.5
}

variable "max_capacity" {
  description = "Serverless v2 maximum capacity or null to skip the serverless v2 scaling configuration"
  type        = number
  default     = null
}

variable "cluster_instances" {
  description = "Cluster instances"
  type = map(object({
    name                   = string
    instance_class         = string
    instance_name_override = optional(string)
  }))
  default = {}
}

variable "tags" {
  description = "Tags for the DB Cluster and instances"
  type        = map(string)
  default     = {}
}
