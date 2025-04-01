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

resource "aws_vpc_security_group_ingress_rule" "ingress" {
  count                        = length(var.ingress-rules)
  security_group_id            = var.security_group_id
  ip_protocol                  = var.ingress-rules[count.index].ip_protocol
  cidr_ipv4                    = var.ingress-rules[count.index].cidr_block
  to_port                      = var.ingress-rules[count.index].to_port
  from_port                    = var.ingress-rules[count.index].from_port
  referenced_security_group_id = var.ingress-rules[count.index].security_group
}