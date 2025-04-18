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
  description = "Purpose of the SSM Endpoint"
}
variable "tags" {
  type        = map(string)
  description = "Default tags to be associated with the Resource"
  default     = {}
}

variable "description" {
  type    = string
  default = ""
}

variable "instance_type" {
  type    = string
  default = null
}

variable "vpc_security_group_ids" {
  type = list(string)
}

variable "instanceProfile_arn" {
  type    = string
  default = null
}

variable "disk_size" {
  type    = number
  default = 10
}
variable "enable_encryption_at_rest" {
  type    = bool
  default = false
}
variable "kms_key_id" {
  type        = string
  description = "KMS Key ID to be used for encryption"
  default     = null
}
variable "imds_enabled" {
  type        = string
  description = "Flag to enable IMDS"
  default     = "required"
}
variable "user_data" {
  type        = string
  description = "User data to be passed to the EC2 instance"
  default     = null
}
variable "ssh_key_name" {
  type    = string
  default = null
}
variable "instance_initiated_shutdown_behavior" {
  type    = string
  default = null
}
variable "image_id" {
  type    = string
  default = null
}