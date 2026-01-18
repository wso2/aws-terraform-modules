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

variable "gateway_name" {
  type        = string
  description = "The name for the Internet Gateway"
}

variable "gateway_abbreviation" {
  type        = string
  description = "The abbreviation for the Internet Gateway resource name"
  default     = "ig"
}

variable "tags" {
  type        = map(string)
  description = "Default tags to be associated with the resource"
}

variable "vpc_ids" {
  type        = list(string)
  description = "List of VPC IDs to associate with the Gateway"
  default     = []
}
