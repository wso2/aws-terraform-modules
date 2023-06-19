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

# Create aws_network_acl_rule for each var.acl_rule
resource "aws_network_acl_rule" "acl_rule" {
  count = length(var.acl_rule)

  network_acl_id = var.network_acl_rule_id
  egress         = var.acl_rule[count.index].egress
  protocol       = var.acl_rule[count.index].protocol
  rule_no        = var.acl_rule[count.index].rule_no
  rule_action    = var.acl_rule[count.index].rule_action
  cidr_block     = var.acl_rule[count.index].cidr_block
  from_port      = var.acl_rule[count.index].from_port
  to_port        = var.acl_rule[count.index].to_port
}
