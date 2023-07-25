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
  type        = bool
  description = "Auto accept connection from the peering network, Peer should be in the same account"
  default     = null
}
variable "accepter_allow_remote_vpc_dns_resolution" {
  type        = bool
  description = "Allow Accepter to use remote vpc for dns resolution"
}
variable "accepter_allow_classic_link_to_remote_vpc" {
  type        = bool
  description = "Allow Accepter Classic EC2 instances to communicate with the Instances in the Remote VPC"
  default     = false
}
variable "accepter_allow_vpc_to_remote_classic_link" {
  type        = bool
  description = "Allow Accepter instances to communicate with the Classic Instances in the Remote VPC"
  default     = false
}
variable "requester_allow_remote_vpc_dns_resolution" {
  type        = bool
  description = "Allow Requester to use remote vpc for dns resolution"
}
variable "requester_allow_classic_link_to_remote_vpc" {
  type        = bool
  description = "Allow Requester Classic EC2 instances to communicate with the Instances in the Remote VPC"
  default     = false
}
variable "requester_allow_vpc_to_remote_classic_link" {
  type        = bool
  description = "Allow Requester instances to communicate with the Classic Instances in the Remote VPC"
  default     = false
}
variable "tags" {
  type        = map(string)
  description = "A mapping of tags to assign to the resource"
  default     = {}
}
variable "vpc_name" {
  type        = string
  description = "Name of the VPC"
}
variable "peer_vpc_name" {
  type        = string
  description = "Name of the VPC"
}
