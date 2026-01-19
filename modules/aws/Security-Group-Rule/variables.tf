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

variable "rules" {
  type = list(object({
    direction       = string
    to_port         = number
    from_port       = number
    protocol        = string
    cidr_blocks     = list(string)
    security_groups = list(string)
    prefix_list_ids = list(string)
  }))
  description = "List of rules to be added to the security group"
}
variable "security_group_id" {
  type        = string
  description = "Security Group to associate rules with"
}
