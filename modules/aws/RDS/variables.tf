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

variable "availability_zone" {
  description = "Availability zone"
  type        = string
}

variable "backup_retention_period" {
  description = "Backup retention period"
  type        = number
  default     = 7
}

variable "performance_insights_enabled" {
  description = "Specifies whether Performance Insights are enabled."
  type        = bool
  default     = true
}

variable "performance_insights_kms_key_id" {
  description = "The ARN for the KMS key to encrypt Performance Insights data."
  type        = string
  default     = null
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

variable "deletion_protection" {
  description = "Deletion protection"
  type        = bool
<<<<<<< HEAD
  default     = false
=======
  default     = true
>>>>>>> upstream/main
}

variable "db_subnet_group_name" {
  description = "DB subnet group name"
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

variable "license_model" {
  description = "License model"
  type        = string
  default     = null
}

variable "database_port" {
  description = "Database port"
  type        = number
  default     = 3306
}

variable "backup_window" {
  description = "Preferred backup window"
  type        = string
  default     = "07:00-09:00"
}

variable "allocated_storage" {
  description = "Allocated storage"
  type        = number
  default     = 20
}

variable "instance_class" {
  description = "Instance class"
  type        = string
}

variable "storage_type" {
  description = "Storage type"
  type        = string
  default     = "gp2"
}

variable "skip_final_snapshot" {
  description = "Flag to skip final snapshot"
  type        = bool
  default     = false
}

variable "publicly_accessible" {
  description = "Flag to make the DB publicly accessible"
  type        = bool
  default     = false
}

variable "tags" {
<<<<<<< HEAD
  type        = map(string)
  description = "Tags for string"
  default     = {}
}

variable "project" {
  type        = string
  description = "Name of the project"
}

variable "environment" {
  type        = string
  description = "Name of the environment"
}

variable "region" {
  type        = string
  description = "Code of the region"
}

variable "application" {
  type        = string
  description = "Purpose of the EKS Cluster"
}

variable "vpc_security_group_ids" {
  type        = list(string)
  description = "List of security group ids"
}

variable "storage_encrypted" {
  type        = bool
  description = "Flag to enable storage encryption"
=======
  description = "Tags for string"
  type        = map(string)
  default     = {}
}

variable "vpc_security_group_ids" {
  description = "List of security group ids"
  type        = list(string)
}

variable "storage_encrypted" {
  description = "Flag to enable storage encryption"
  type        = bool
>>>>>>> upstream/main
  default     = true
}

variable "kms_key_id" {
<<<<<<< HEAD
  type        = string
  description = "KMS key id"
=======
  description = "KMS key id"
  type        = string
>>>>>>> upstream/main
  default     = null
}
