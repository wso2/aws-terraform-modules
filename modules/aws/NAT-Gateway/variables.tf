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

variable "nat_gateway_name" {
  type        = string
  description = "The name for the NAT Gateway"
}

variable "nat_gateway_abbreviation" {
  type        = string
  description = "The abbreviation for the NAT Gateway resource name"
  default     = "natg"
}

variable "eip_abbreviation" {
  type        = string
  description = "The abbreviation for the Elastic IP resource name"
  default     = "eip"
}

variable "shield_abbreviation" {
  type        = string
  description = "The abbreviation for the Shield Protection resource name"
  default     = "shld"
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
variable "enable_shield_protection" {
  type        = bool
  description = "Enable AWS Shield Protection for the NAT Gateway"
  default     = false
}
