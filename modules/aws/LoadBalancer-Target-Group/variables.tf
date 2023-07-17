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
  description = "Purpose of the EC2 Instance"
}
variable "target_type" {
  type        = string
  description = "Type of the target"
}
variable "port" {
  type        = number
  description = "Primary port to be exposed within the Target Group"
}
variable "protocol" {
  type        = string
  description = "Protocol to be used for the Target Group"
}
variable "vpc_id" {
  type        = string
  description = "VPC ID"
}
variable "target_group_attachments" {
  type = map(object({
    target_id         = string
    availability_zone = optional(string)
    port              = optional(number)
  }))
  description = "List of target group attachments"
}
