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
variable "tags" {
  type        = map(string)
  description = "The tags for the resources"
  default     = {}
}
variable "key_arn" {
  type        = string
  description = "The ARN of the KMS key"
}
