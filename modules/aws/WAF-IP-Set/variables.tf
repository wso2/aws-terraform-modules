# -------------------------------------------------------------------------------------
#
# Copyright (c) 2026, WSO2 LLC. (http://www.wso2.com). All Rights Reserved.
#
# This software is the property of WSO2 LLC. and its suppliers, if any.
# Dissemination of any information or reproduction of any material contained
# herein in any form is strictly forbidden, unless permitted by WSO2 expressly.
# You may not alter or remove any copyright or other notice from copies of this content.
#
# --------------------------------------------------------------------------------------

variable "name" {
  description = "Name of the WAF IP Set"
  type        = string
}

variable "scope" {
  description = "The scope of the WAF IP Set. Valid values are REGIONAL or CLOUDFRONT"
  type        = string
  default     = "REGIONAL"
}

variable "inbound_allowed_cidrs" {
  description = "A list of CIDR blocks to allow inbound traffic from"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "A map of tags to assign to the resource"
  type        = map(string)
  default     = {}
}
