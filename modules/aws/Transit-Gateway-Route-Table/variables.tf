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

variable "routes" {
  type = map(object({
    destination_cidr_block        = string
    transit_gateway_attachment_id = string
  }))
  description = "The routes to be added to the transit gateway route table."
}
variable "transit_gateway_id" {
  type        = string
  description = "The ID of the transit gateway."
}