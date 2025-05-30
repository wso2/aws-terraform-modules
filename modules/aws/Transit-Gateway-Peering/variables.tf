# -------------------------------------------------------------------------------------
#
# Copyright (c) 2025, WSO2 LLC. (http://www.wso2.com). All Rights Reserved.
#
# This software is the property of WSO2 LLC. and its suppliers, if any.
# Dissemination of any information or reproduction of any material contained
# herein in any form is strictly forbidden, unless permitted by WSO2 expressly.
# You may not alter or remove any copyright or other notice from copies of this content.
#
# --------------------------------------------------------------------------------------

variable "peer_account_id" {
  description = "The AWS account ID of the peer transit gateway"
  type        = string
}
variable "peer_region" {
  description = "The AWS region of the peer transit gateway"
  type        = string
}
variable "peer_transit_gateway_id" {
  description = "The ID of the peer transit gateway"
  type        = string
}
variable "local_transit_gateway_id" {
  description = "The ID of the local transit gateway"
  type        = string
}
variable "default_tags" {
  description = "Default tags to apply to the transit gateway peering attachment"
  type        = map(string)
  default     = {}
}