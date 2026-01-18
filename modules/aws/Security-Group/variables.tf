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

variable "security_group_name" {
  type        = string
  description = "The name for the Security Group"
}

variable "security_group_abbreviation" {
  type        = string
  description = "The abbreviation for the Security Group resource name"
  default     = "stg"
}

variable "security_group_description" {
  type        = string
  description = "Description of the Security Group"
}

variable "rules" {
  type = list(object({
    direction       = string
    to_port         = number
    from_port       = number
    protocol        = string
    cidr_blocks     = list(string)
    security_groups = list(string)
  }))
  description = "List of rules to be added to the security group"
}

variable "vpc_id" {
  type        = string
  description = "VPC that Security group should be associated with"
}

variable "tags" {
  type        = map(string)
  description = "Tags to be added to the security group"
  default     = {}
}
