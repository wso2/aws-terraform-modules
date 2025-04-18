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
  subnet_id                = var.subnet_id
  connectivity_type        = var.connectivity_type
  allocation_id            = var.allocation_id
  secondary_allocation_ids = var.secondary_allocation_ids
  tags                     = local.tags
}