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
variable "vpc_id" {
  type        = string
  description = "ID of the VPC the endpoint is associated with"
}
variable "endpoint_security_group_ids" {
  type        = list(string)
  description = "Security groups that should be associated with the EP"
  default     = []
}
variable "subnet_ids" {
  type        = list(string)
  description = "Subnet IDs where the VPC EP should exist"
  default     = []
}
variable "endpoint_private_dns_enabled" {
  type        = bool
  description = "ID of the VPC the endpoint is associated with"
  default     = true
}
variable "gateway_lb_service_name" {
  type        = string
  description = "Service endpoint to be used for the VPC Endpoint"
}
variable "gateway_lb_service_type" {
  type        = string
  description = "Service Type to be used for the VPC Endpoint"
}
variable "service_short_hand_name" {
  type        = string
  description = "Service endpoint to be used for the VPC Endpoint"
}
