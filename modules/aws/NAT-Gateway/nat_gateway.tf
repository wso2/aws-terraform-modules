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

resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.eip.id
  subnet_id     = var.subnet_id

  tags = local.natg_tags

  depends_on = [
    aws_eip.eip
  ]
}

resource "aws_eip" "eip" {
  tags = local.eip_tags
}

resource "aws_shield_protection" "shield_protection" {
  count        = var.enable_shield_protection == true ? 1 : 0
  name         = local.shield_name
  resource_arn = aws_eip.eip.id

  tags = var.tags
}
