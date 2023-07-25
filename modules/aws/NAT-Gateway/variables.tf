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
  description = "Purpose of the Subnet"
}
variable "cidr_block" {
  type        = string
  description = "CIDR block to be used for the VPC"
}
variable "tags" {
  type        = map(string)
  description = "Default tags to be associated with the Resource"
  default     = {}
}
variable "vpc_id" {
  type        = string
  description = "ID of the VPC"
}
variable "availability_zone" {
  type        = string
  description = "Avaialability zone of the Subnet"
  default     = null
}

variable "custom_routes" {
  type = list(object({
    cidr_block = string
    ep_type    = string
    ep_id      = string
  }))
  description = "Rules to be associated with the EC2 Subnet if provided"
  default     = []
}
