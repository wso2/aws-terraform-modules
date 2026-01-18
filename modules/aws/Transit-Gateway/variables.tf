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
variable "transit_gateway_name" {
  type        = string
  description = "Name of the Transit Gateway"
}

variable "transit_gateway_abbreviation" {
  type        = string
  description = "Abbreviation for the Transit Gateway"
  default     = "tgw"
}

variable "description" {
  type        = string
  description = "Description of the Transit Gateway"
}

variable "tags" {
  type        = map(string)
  description = "Default tags for the Transit Gateway"
  default     = {}
}

variable "dns_support" {
  type        = string
  description = "Whether DNS support is enabled"
  default     = "enable"
}

variable "default_route_table_propagation" {
  type        = string
  description = "Whether resource default route table propagation is enabled"
  default     = "enable"
}

variable "default_route_table_association" {
  type        = string
  description = "Whether resource default route table association is enabled"
  default     = "enable"
}

variable "auto_accept_shared_attachments" {
  type        = string
  description = "Whether resource auto accept shared attachments is enabled"
  default     = "enable"
}

variable "multicast_support" {
  type        = string
  description = "Whether multicast support is enabled"
  default     = "enable"
}
