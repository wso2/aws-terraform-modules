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

variable "peer_owner_id" {
  type        = string
  description = "Owner ID of the peering network"
  default     = null
}
variable "peer_vpc_id" {
  type        = string
  description = "VPC Id of the peering network"
}
variable "vpc_id" {
  type        = string
  description = "VPC Id of the peering network"
}
variable "auto_accept" {
  type        = bool
  description = "Auto accept connection from the peering network, Peer should be in the same account"
  default     = false
}
variable "peer_region" {
  type        = string
  description = "The region of the accepter VPC of the VPC Peering Connection. auto_accept must be false, and use the aws_vpc_peering_connection_accepter to manage the accepter side."
  default     = null
}
