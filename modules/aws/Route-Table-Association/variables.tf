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

variable "gateway_id" {
  type        = string
  description = "The ID of the Internet/VPC Gateway to which the route table should be associated with"
  default     = null
}
variable "subnet_id" {
  type        = string
  description = "The ID of the subnet to which the route table should be associated with"
  default     = null
}
variable "route_table_id" {
  type        = string
  description = "The ID of the route table to which the route should be added"
}
