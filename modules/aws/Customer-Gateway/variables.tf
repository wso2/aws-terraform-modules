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

variable "default_tags" {
  type        = map(string)
  description = "Default tags for the Subnet resource"
  default     = {}
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
variable "bgp_asn" {
  type        = number
  description = "The BGP Autonomous System Number (ASN) for the router"
}
variable "customer_gateway_ip_address" {
  type        = string
  description = "The customer-side IP address of the BGP interface"
  default     = null
}
variable "type" {
  type        = string
  description = "The type of Customer gateway"
}
variable "certificate_arn" {
  type        = string
  description = "The ARN of the customer gateway certificate"
  default     = null
}
variable "device_name" {
  type        = string
  description = "The name of the VPN device"
  default     = null
}
