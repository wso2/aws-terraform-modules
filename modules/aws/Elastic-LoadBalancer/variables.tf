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

variable "elb_abbreviation" {
  description = "Abbreviation for the Elastic Load Balancer"
  type        = string
  default     = "elb"
}
variable "elb_name" {
  description = "Name of the Elastic Load Balancer"
  type        = string
}
variable "internal_usage_flag" {
  type        = string
  description = "Flag to indicate whether the EC2 instance is for internal usage or not"
  default     = false
}
variable "security_group_ids" {
  type        = list(string)
  description = "List of security group IDs"
  default     = []
}
variable "subnet_ids" {
  type        = map(string)
  description = "List of subnet IDs"
  default     = {}
}
variable "deletion_protection_flag" {
  type        = string
  description = "Flag to indicate whether the ALB instance is protected from accidental termination or not"
  default     = true
}
variable "tags" {
  type        = map(string)
  description = "Default tags to be added to the ALB instance"
  default     = {}
}
variable "load_balancer_type" {
  type        = string
  description = "Type of the load balancer"
}
variable "private_ip_addresses" {
  type        = map(string)
  description = "List of private IP addresses"
  default     = {}
}
variable "enable_shield_protection" {
  type        = string
  description = "Flag to indicate whether the ALB instance is protected by AWS Shield or not"
  default     = false
}
variable "shield_protection_abbreviation" {
  description = "Abbreviation for the Shield Protection"
  type        = string
  default     = "elb-eip-shield-protection"
}
