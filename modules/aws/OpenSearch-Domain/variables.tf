# -------------------------------------------------------------------------------------
#
# Copyright (c) 2024, WSO2 LLC. (http://www.wso2.com). All Rights Reserved.
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
  description = "Purpose of the EKS Cluster"
}
variable "tags" {
  type        = map(string)
  description = "Tags for the resources"
  default     = {}
}
variable "log_publishing_options" {
  type = object({
    cloudwatch_log_group_arn = string
    log_type                 = string
  })
  description = "Log publishing options"
  default     = null
}
variable "kms_key_arn" {
  type        = string
  description = "KMS Key ARN"
  default     = null
}
variable "engine_version" {
  type        = string
  description = "OpenSearch Cluster Engine Version"
  default     = "7.10"
}
variable "ebs_volume" {
  type = object({
    volume_size = number
    volume_type = string
    iops        = number
    throughput  = number
  })
  description = "EBS Volume Configuration"
  default     = null
}
variable "automated_snapshot_start_hour" {
  type        = number
  description = "The hour in UTC during which the service takes an automated daily snapshot of the indices in the domain"
  default     = 0
}
variable "zone_awareness_enabled" {
  type        = bool
  description = "Specifies whether zone awareness is enabled"
  default     = false
}
variable "instance_count" {
  type        = number
  description = "The number of instances in the domain"
  default     = 1
}
variable "instance_type" {
  type        = string
  description = "The instance type for the OpenSearch cluster"
}
variable "availability_zone_count" {
  type        = number
  description = "The number of Availability Zones for the domain"
  default     = 1
}
variable "advanced_security_options" {
  type = object({
    enabled                        = bool
    internal_user_database_enabled = bool
    master_user_options = object({
      master_user_arn      = optional(string)
      master_user_name     = optional(string)
      master_user_password = optional(string)
    })
  })
  description = "Advanced Security Options"
  sensitive   = true
  default     = null
}
variable "vpc_options" {
  type = object({
    security_group_ids = list(string)
    subnet_ids         = list(string)
  })
  description = "VPC Options"
  default     = null
}
variable "advanced_options" {
  type        = map(string)
  description = "Key-value string pairs to specify advanced configuration options"
  default     = {}
}
