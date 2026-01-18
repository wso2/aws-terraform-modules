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

variable "firewall_name" {
  type        = string
  description = "The name for the Network Firewall"
}

variable "firewall_abbreviation" {
  type        = string
  description = "The abbreviation for the Network Firewall resource name"
  default     = "nfw"
}

variable "firewall_policy_abbreviation" {
  type        = string
  description = "The abbreviation for the Firewall Policy resource name"
  default     = "nfwp"
}

variable "tags" {
  description = "The tags for the resources"
  type        = map(any)
  default     = {}
}

variable "description" {
  description = "Description for the resources"
  default     = ""
  type        = string
}

variable "fivetuple_stateful_rule_group" {
  description = "Config for 5-tuple type stateful rule group"
  default     = []
  type        = any
}

variable "domain_stateful_rule_group" {
  description = "Config for domain type stateful rule group"
  default     = []
  type        = any
}
variable "suricata_stateful_rule_group" {
  description = "Config for Suricata type stateful rule group"
  default     = []
  type        = any
}
variable "stateless_rule_group" {
  description = "Config for stateless rule group"
  type        = any
  default     = []
}
variable "subnet_mapping" {
  description = "Subnet ids mapping to have individual firewall endpoint"
  type        = list(string)
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "stateless_default_actions" {
  description = "Default stateless Action"
  type        = string
  default     = "forward_to_sfe"
}

variable "stateless_fragment_default_actions" {
  description = "Default Stateless action for fragmented packets"
  type        = string
  default     = "forward_to_sfe"
}

variable "firewall_policy_change_protection" {
  type        = string
  description = "(Option) A boolean flag indicating whether it is possible to change the associated firewall policy"
  default     = false
}

variable "subnet_change_protection" {
  type        = string
  description = "(Optional) A boolean flag indicating whether it is possible to change the associated subnet(s)"
  default     = false
}

variable "logging_config" {
  description = "logging config for cloudwatch logs created for network firewall"
  type        = map(any)
  default     = {}
}

variable "aws_managed_rule_group" {
  description = "List of AWS managed rule group arn"
  type        = list(any)
  default     = []
}
