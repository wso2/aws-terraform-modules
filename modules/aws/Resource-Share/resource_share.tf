# -------------------------------------------------------------------------------------
#
# Copyright (c) 2024, WSO2 LLC. (http://www.wso2.com). All Rights Reserved.
#
# This software is the property of WSO2 LLC. and its suppliers, if any.
# Dissemination of any information or reproduction of any material contained
# herein in any form is strictly forbidden, unless permitted by WSO2 expressly.
# You may not alter or remove any copyright or other notice from copies of this content.
#
# --------------------------------------------------------------------------------------

resource "aws_ram_resource_share" "ram_resource_share" {
  name = "terraform-example"
  tags = var.tags
}

# Share the transit gateway...
resource "aws_ram_resource_association" "aws_ram_resource_association" {
  resource_arn       = var.resource_arn
  resource_share_arn = aws_ram_resource_share.ram_resource_share.id
}

# ...with the second account.
resource "aws_ram_principal_association" "ram_principal_association" {
  principal          = var.account_id
  resource_share_arn = aws_ram_resource_share.ram_resource_share.id
}
