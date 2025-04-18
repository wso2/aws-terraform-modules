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
variable "tags" {
  type        = map(string)
  description = "Default tags to be associated with the Resource"
  default     = {}
}
variable "subnet_id" {
  type        = string
  description = "ID of the Subnet to host the NAT Gateway"
  default     = null
}

variable "allocation_id" {
  type        = string
  description = "The Allocation ID of the Elastic IP address for the NAT Gateway. Required for connectivity_type of public."
}

variable "secondary_allocation_ids" {
  type        = list(string)
  default     = []
  description = "A list of secondary allocation EIP IDs for this NAT Gateway."
}

variable "connectivity_type" {
  type        = string
  default     = "public"
  description = "Connectivity type for the NAT Gateway. Valid values are private and public. Defaults to public."
}

variable "secondary_private_ip_address_count" {
  type        = number
  default     = 0
  description = "The number of secondary private IPv4 addresses you want to assign to the Private NAT Gateway"
}