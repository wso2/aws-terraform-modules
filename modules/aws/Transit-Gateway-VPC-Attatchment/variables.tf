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

variable "vpc_id" {
  type = string
    description = "VPC ID to be used for the Transit Gateway attachment"
}
variable "subnet_ids" {
  type = list(string)
  description = "Subnet IDs to be used for the Transit Gateway attachment"
}
variable "transit_gateway_id" {
  type = string
}
variable "appliance_mode_support" {
  type = string
  description = "Appliance mode support for the Transit Gateway attachment"
  default = "disable"
}
variable "tags" {
  default = {}
  description = "Tags to be used for the Transit Gateway attachment"
  type = map(string)
}
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
