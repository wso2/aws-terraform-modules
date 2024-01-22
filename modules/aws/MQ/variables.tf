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
  description = "Purpose of the EKS Cluster"
}
variable "engine_version" {
  type = string
}
variable "instance_type" {
  type = string
}
variable "security_group_ids" {
  type    = list(string)
  default = null
}
variable "audit_logs_enabled" {
  type    = bool
  default = false
}
variable "general_logs_enabled" {
  type    = bool
  default = false
}
variable "users" {
  type = list(object({
    username       = string
    password       = string
    console_access = bool
  }))
  default = []
}
variable "subnet_ids" {
  type    = list(string)
  default = []
}
variable "public_access" {
  type    = bool
  default = false
}
variable "auto_minor_version_upgrade" {
  type    = bool
  default = false
}
