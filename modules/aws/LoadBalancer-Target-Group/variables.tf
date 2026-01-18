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

variable "target_group_name" {
  type        = string
  description = "The name for the Load Balancer Target Group"
}

variable "target_group_abbreviation" {
  type        = string
  description = "The abbreviation for the Target Group resource name"
  default     = "tg"
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

variable "tags" {
  type        = map(string)
  description = "Tags to be added to the resources"
  default     = {}
}
