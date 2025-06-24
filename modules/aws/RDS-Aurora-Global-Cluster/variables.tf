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

variable "database_name" {
  description = "Database name"
  type        = string
  default     = null
}

variable "engine" {
  description = "Engine to be used for the DB Cluster"
  type        = string
  default     = null
}

variable "engine_version" {
  description = "Engine version to be used for the DB Cluster"
  type        = string
  default     = null
}

variable "deletion_protection" {
  description = "Enable deletion protection for the DB Cluster"
  type        = bool
  default     = true
}

variable "source_db_cluster_identifier" {
  description = "Instance class for the DB Cluster"
  type        = string
  default     = null
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

variable "storage_encrypted" {
  description = "Enable storage encryption for the DB Cluster"
  type        = bool
  default     = true
}
