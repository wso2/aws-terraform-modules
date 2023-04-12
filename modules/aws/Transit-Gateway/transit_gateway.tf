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

resource "aws_ec2_transit_gateway" "ec2_transit_gateway" {
  name                            = local.vpc_name
  description                     = var.description
  dns_support                     = var.dns_support
  multicast_support               = var.multicast_support
  default_route_table_association = var.default_route_table_association
  default_route_table_propagation = var.default_route_table_propagation
  auto_accept_shared_attachments  = var.auto_accept_shared_attachments
  tags                            = var.default_tags
}
