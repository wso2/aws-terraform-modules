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

variable "private_dns_zone_id" {
  description = "The ID of the private DNS zone to associate with the VPC."
  type        = string
}

variable "vpc_id" {
  description = "The ID of the VPC to associate with the private DNS zone."
  type        = string
}
