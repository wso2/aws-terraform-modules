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

variable "vpc_id" {
  type        = string
  description = "ID of the VPC to associate with the ACL"
}
variable "subnet_ids" {
  type        = list(string)
  description = "Subnets to be associated with the ACL"
}
variable "ingress_rules" {
  type = list(object({
    protocol   = string
    rule_no    = string
    action     = string
    cidr_block = string
    from_port  = number
    to_port    = number
  }))
  description = "List of ingress rules"
}

variable "egress_rules" {
  type = list(object({
    protocol   = string
    rule_no    = string
    action     = string
    cidr_block = string
    from_port  = number
    to_port    = number
  }))
  description = "List of egress rules"
}
variable "default_tags" {
  type        = map(string)
  description = "Tags to be associated with the EKS"
  default     = {}
}
