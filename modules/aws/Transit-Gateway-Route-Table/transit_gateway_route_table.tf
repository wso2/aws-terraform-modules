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

resource "aws_ec2_transit_gateway_route_table" "ec2_transit_gateway_route_table" {
  transit_gateway_id = var.transit_gateway_id
}

resource "aws_ec2_transit_gateway_route" "ec2_transit_gateway_route" {
  for_each                       = var.routes
  destination_cidr_block         = each.value.destination_cidr_block
  transit_gateway_attachment_id  = each.value.transit_gateway_attachment_id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.ec2_transit_gateway_route_table.id
}
