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

resource "aws_security_group_rule" "security_group_rule" {
  count = length(var.rules)

  security_group_id        = var.security_group_id
  type                     = var.rules[count.index].direction
  from_port                = var.rules[count.index].from_port
  to_port                  = var.rules[count.index].to_port
  protocol                 = var.rules[count.index].protocol
  cidr_blocks              = length(var.rules[count.index].cidr_blocks) > 0 ? var.rules[count.index].cidr_blocks : null
  prefix_list_ids          = length(var.rules[count.index].prefix_list_ids) > 0 ? var.rules[count.index].prefix_list_ids : null
  source_security_group_id = length(var.rules[count.index].security_groups) > 0 ? var.rules[count.index].security_groups[0] : null
  description              = try(var.rules[count.index].description, null)
}
