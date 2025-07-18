# -------------------------------------------------------------------------------------
#
# Copyright (c) 2025, WSO2 LLC. (https://www.wso2.com) All Rights Reserved.
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

variable "allow_major_version_upgrade" {
  description = "Allow major version upgrade"
  type        = bool
  default     = false
}

variable "availability_zones" {
  description = "Availability zones"
  type        = list(string)
}

variable "backtrack_window" {
  description = "Backtrack window"
  type        = number
  default     = 0
}

variable "backup_retention_period" {
  description = "Backup retention period"
  type        = number
  default     = 0
}

variable "master_username" {
  description = "Master username"
  type        = string
}

variable "master_password" {
  description = "Master password, If not provided Secret Manager will handle the password"
  type        = string
  sensitive   = true
  default     = null
}

variable "database_name" {
  description = "Database name"
  type        = string
}

variable "db_cluster_instance_class" {
  description = "DB cluster instance class"
  type        = string
  default     = null
}

variable "deletion_protection" {
  description = "Deletion protection"
  type        = bool
  default     = false
}

variable "db_subnet_group_name" {
  description = "DB subnet group name"
  type        = string
}

variable "db_cluster_parameter_group_name" {
  description = "DB cluster parameter group name"
  type        = string
  default     = null
}

variable "db_instance_parameter_group_name" {
  description = "DB instance parameter group name"
  type        = string
  default     = null
}

variable "enable_http_endpoint" {
  description = "Flag to Enable HTTP endpoint"
  type        = bool
  default     = false
}

variable "engine_mode" {
  description = "Engine mode to be used for the DB Cluster"
  type        = string
}

variable "engine" {
  description = "Engine to be used for the DB Cluster"
  type        = string
}

variable "engine_version" {
  description = "Engine version to be used for the DB Cluster"
  type        = string
}

variable "enabled_cloudwatch_log_exports" {
  description = "List of log types to export to cloudwatch"
  type        = list(string)
  default     = []
}

variable "iam_database_authentication_enabled" {
  description = "Flag to enable IAM database authentication"
  type        = bool
  default     = false
}

variable "network_type" {
  description = "Network type. Can be IPV4 or DUAL"
  type        = string
  default     = "IPV4"
}

variable "database_port" {
  description = "Database port"
  type        = number
  default     = 3306
}

variable "preferred_backup_window" {
  description = "Preferred backup window"
  type        = string
  default     = "07:00-09:00"
}

variable "preferred_maintenance_window" {
  description = "Preferred maintenance window"
  type        = string
  default     = "sun:10:00-sun:14:00"
}

variable "global_cluster_identifier" {
  description = "Global cluster identifier"
  type        = string
  default     = null
}

variable "replication_source_identifier" {
  description = "Replication source identifier"
  type        = string
  default     = null
}

variable "enable_scaling_configuration" {
  description = "Flag to enable scaling configuration"
  type        = bool
  default     = false
}

variable "min_capacity" {
  description = "Minimum capacity for autoscaling"
  type        = number
  default     = null
}

variable "max_capacity" {
  description = "Maximum capacity for autoscaling"
  type        = number
  default     = null
}

variable "cluster_custom_iam_instance_profile" {
  description = "Custom IAM instance profile for all instances"
  type        = string
  default     = null
}

variable "cluster_common_monitoring_interval" {
  description = "Monitoring interval for all instances"
  type        = number
  default     = 0
}

variable "cluster_common_monitoring_role_arn" {
  description = "Monitoring role arn for all instances"
  type        = string
  default     = null
}

variable "cluster_common_performance_insights_enabled" {
  description = "Performance insights enabled for all instances"
  type        = bool
  default     = false
}

variable "engine_lifecycle_support" {
  description = "The life cycle type for this DB instance."
  type        = string
  default     = "open-source-rds-extended-support"
}

variable "publicly_accessible" {
  description = "Flag to make the DB publicly accessible"
  type        = bool
  default     = false
}

variable "cluster_instances" {
  description = "List of cluster instances"
  type = map(object({
    name                         = string
    custom_iam_instance_profile  = optional(string)
    db_parameter_group_name      = optional(string)
    instance_class               = optional(string)
    monitoring_interval          = optional(number, 0)
    monitoring_role_arn          = optional(string)
    performance_insights_enabled = optional(bool, false)
    preferred_backup_window      = optional(string)
    preferred_maintenance_window = optional(string)
  }))
}

variable "tags" {
  description = "Tags for string"
  type        = map(string)
  default     = {}
}

variable "project" {
  description = "Name of the project"
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

variable "application" {
  description = "Purpose of the EKS Cluster"
  type        = string
}

variable "vpc_security_group_ids" {
  description = "List of security group ids"
  type        = list(string)
}

variable "storage_encrypted" {
  description = "Flag to enable storage encryption"
  type        = bool
  default     = true
}

variable "kms_key_id" {
  description = "KMS key id"
  type        = string
  default     = null
}

variable "skip_final_snapshot" {
  description = "Flag to skip final snapshot"
  type        = bool
  default     = false
}

variable "final_snapshot_identifier" {
  description = "Final snapshot identifier"
  type        = string
  default     = null

  validation {
    condition     = var.skip_final_snapshot || (var.final_snapshot_identifier != null && var.final_snapshot_identifier != "")
    error_message = "You must specify final_snapshot_identifier if skip_final_snapshot is false."
  }
}

variable "manage_master_user_password" {
  description = "Flag to manage master user password"
  type        = bool
  default     = false
}
