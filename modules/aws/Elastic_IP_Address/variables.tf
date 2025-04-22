# -------------------------------------------------------------------------------------
#
# Copyright (c) 2025, WSO2 LLC. (http://www.wso2.com). All Rights Reserved.
#
# This software is the property of WSO2 LLC. and its suppliers, if any.
# Dissemination of any information or reproduction of any material contained
# herein in any form is strictly forbidden, unless permitted by WSO2 expressly.
# You may not alter or remove any copyright or other notice from copies of this content.
#
# --------------------------------------------------------------------------------------

variable "eip_domain" {
  description = "The domain of the EIP"
  type        = string
}
variable "shield_protection_enabled" {
  description = "Enable AWS Shield Protection"
  type        = bool
}
variable "default_tags" {
  description = "The default tags for the EIP"
  type        = map(string)
}
variable "project" {
  description = "Name of the project"
  type        = string
}
variable "application" {
  description = "Purpose of the EC2 Instance"
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
