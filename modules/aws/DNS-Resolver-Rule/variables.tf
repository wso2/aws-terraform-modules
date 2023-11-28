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

variable "tags" {
  type        = map(string)
  default     = {}
  description = "tags to be associated with the rule"
}
variable "target_ip" {
  type        = string
  description = "Target IP to resolve the DNS query"
}
variable "resolver_endpoint_id" {
  type        = string
  description = "Resolver endpoint ID to associate the rule with"
}
variable "rule_type" {
  type        = string
  description = "Rule type to be created"
  default     = "FORWARD"
}
variable "name" {
  type        = string
  description = "Name of the rule"
}
variable "domain_name" {
  type        = string
  description = "Domain name to be resolved"
}
variable "vpc_id" {
  type        = string
  description = "VPC ID to associate the rule with"
}
