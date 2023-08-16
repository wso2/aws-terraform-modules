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
  description = "Purpose of the Parameter Group"
}
variable "node_type" {
  type        = string
  description = "Node type of the Elastic Cache"
}
variable "parameter_group_name" {
  type        = string
  description = "Name of the Parameter Group"
}
variable "engine_version" {
  type        = string
  description = "Version of the Elastic Cache"
}
variable "final_snapshot_identifier" {
  type        = string
  description = "Name of the final snapshot"
  default     = null
}
variable "availability_zones" {
  type        = list(string)
  description = "Availability zones of the Elastic Cache"
  default     = null
}
variable "apply_immediately" {
  type        = bool
  description = "Apply db changes immediately or wait for the next maintenance window"
  default     = false
}
variable "auto_minor_version_upgrade" {
  type        = bool
  description = "Auto minor version upgrade of the Elastic Cache"
  default     = true
}
variable "tags" {
  type        = map(string)
  description = "Tags to be added to the Elastic Cache"
  default     = {}
}
variable "port" {
  type        = number
  description = "Port of the Elastic Cache"
  default     = 6379
}
variable "snapshot_retention_limit" {
  type        = number
  description = "Snapshot retention limit of the Elastic Cache"
  default     = null
}
variable "snapshot_window" {
  type        = string
  description = "Snapshot window of the Elastic Cache"
  default     = null
}
variable "maintenance_window" {
  type        = string
  description = "Maintenance window of the Elastic Cache"
  default     = null
}
variable "security_group_ids" {
  type        = list(string)
  description = "Security group ids of the Elastic Cache"
  default     = null
}
variable "subnet_group_name" {
  type        = string
  description = "Subnet IDs of the Elastic Cache"
  default     = null
}
variable "enable_transit_encryption" {
  type        = string
  description = "Enable encryption at transit for redis"
  default     = true
}
variable "at_rest_encryption_enabled" {
  type        = string
  description = "Enable encryption at rest for redis"
  default     = true
}
variable "auth_token" {
  type        = string
  sensitive   = true
  description = "Auth token for redis"
}
variable "num_cache_clusters" {
  type        = number
  description = "Number of cache clusters"
  default     = 1
}
variable "automatic_failover_enabled" {
  type        = bool
  description = "Enable automatic failover"
  default     = false
}
