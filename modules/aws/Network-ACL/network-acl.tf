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

resource "aws_network_acl" "network_acl" {
  vpc_id = var.vpc_id

  # Create egress rules for each var.egress_rule
  dynamic "egress" {
    for_each = var.egress_rules
    content {
      protocol   = egress.value.protocol
      rule_no    = egress.value.rule_no
      action     = egress.value.action
      cidr_block = egress.value.cidr_block
      from_port  = egress.value.from_port
      to_port    = egress.value.to_port
    }
  }

  # Create ingress rules for each var.ingress_rule
  dynamic "ingress" {
    for_each = var.ingress_rules
    content {
      protocol   = ingress.value.protocol
      rule_no    = ingress.value.rule_no
      action     = ingress.value.action
      cidr_block = ingress.value.cidr_block
      from_port  = ingress.value.from_port
      to_port    = ingress.value.to_port
    }
  }

  tags = local.network_acl_tags
}

resource "aws_network_acl_association" "network_acl_association" {
  network_acl_id = aws_network_acl.network_acl.id
  subnet_id      = var.subnet_id
}
