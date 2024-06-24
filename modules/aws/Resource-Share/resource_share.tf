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
  name = join("-", [var.project, var.application, var.environment, var.region])
  tags = var.tags
}

# For each resource arn add it to the share resource.
resource "aws_ram_resource_association" "aws_ram_resource_association" {
  for_each           = var.resource_arns
  resource_arn       = each.value
  resource_share_arn = aws_ram_resource_share.ram_resource_share.id
}

resource "aws_ram_principal_association" "ram_principal_association" {
  principal          = var.account_id
  resource_share_arn = aws_ram_resource_share.ram_resource_share.id
}
