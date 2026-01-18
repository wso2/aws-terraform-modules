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

variable "route_table_name" {
  type        = string
  description = "The name for the Route Table"
}

variable "route_table_abbreviation" {
  type        = string
  description = "The abbreviation for the Route Table resource name"
  default     = "rt"
}

variable "vpc_id" {
  type        = string
  description = "ID of the VPC containing the route table"
}

variable "tags" {
  type        = map(string)
  description = "Tags to be associated with the resource"
  default     = {}
}

variable "custom_routes" {
  type = list(object({
    cidr_block = string
    ep_type    = string
    ep_id      = string
  }))
  description = "Rules to be associated with the Subnet if provided"
  default     = []
}
