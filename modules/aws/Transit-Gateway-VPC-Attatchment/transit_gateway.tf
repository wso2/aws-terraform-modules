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

resource "aws_ec2_transit_gateway_vpc_attachment" "ec2_transit_gateway_vpc_attachment" {
  transit_gateway_id     = var.transit_gateway_id
  vpc_id                 = var.vpc_id
  subnet_ids             = var.subnet_ids
  appliance_mode_support = var.appliance_mode_support

  tags = local.attachment_tags
}
