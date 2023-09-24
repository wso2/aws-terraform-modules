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
variable "acceptance_required" {
  description = "Whether to check for acceptance of the Endpoint service request from service provider"
  default     = true
}
variable "network_load_balancer_arns" {
  description = "ARNs of the network load balancers to be associated with the endpoint service"
  type        = list(string)
  default     = []
}
variable "gateway_load_balancer_arns" {
  description = "ARNs of the gateway load balancers to be associated with the endpoint service"
  type        = list(string)
  default     = []
}
variable "private_dns_name" {
  description = "The private DNS name to be used for the endpoint service"
  type        = string
  default     = null
}
variable "allowed_principals" {
  description = "The ARNs of one or more principals allowed to discover the endpoint service"
  type        = list(string)
  default     = []
}
variable "supported_ip_address_types" {
  description = "The types of IP addresses allowed for the endpoint service"
  type        = list(string)
  default     = ["IPV4"]
}
variable "service_short_hand_name" {
  type        = string
  description = "Service endpoint to be used for the VPC Endpoint"
}
