# -------------------------------------------------------------------------------------
#
# Copyright (c) 2025, WSO2 LLC. (http://www.wso2.com). All Rights Reserved.
#
# This software is the property of WSO2 LLC. and its suppliers, if any.
# Dissemination of any information or reproduction of any material contained
# herein in any form is strictly forbidden, unless permitted by WSO2 expressly.
# You may not alter or remove any copyright or other notice from copies of this content.
#
# --------------------------------------------------------------------------------------

resource "aws_ec2_transit_gateway_peering_attachment" "transit_gateway_peering_attachment" {
  peer_account_id         = var.peer_account_id
  peer_region             = var.peer_region
  peer_transit_gateway_id = var.peer_transit_gateway_id
  transit_gateway_id      = var.local_transit_gateway_id
  tags                    = var.default_tags
}
# Look up this module's own attachment by its id, so the lookup stays unique even when the TGW has more than one peering.
data "aws_ec2_transit_gateway_peering_attachment" "peer_transit_gateway_peering_attachment" {
  filter {
    name   = "transit-gateway-id"
    values = [var.peer_transit_gateway_id]
  }
  filter {
    name   = "transit-gateway-attachment-id"
    values = [aws_ec2_transit_gateway_peering_attachment.transit_gateway_peering_attachment.id]
  }
  depends_on = [aws_ec2_transit_gateway_peering_attachment.transit_gateway_peering_attachment]
}

# Accept from the peer side via the data source (accepting via the resource id is rejected by AWS).
resource "aws_ec2_transit_gateway_peering_attachment_accepter" "transit_gateway_peering_attachment_accepter" {
  transit_gateway_attachment_id = data.aws_ec2_transit_gateway_peering_attachment.peer_transit_gateway_peering_attachment.id
}
