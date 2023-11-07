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

resource "aws_vpc_endpoint_route_table_association" "vpc_endpoint_route_table_association" {
  count           = length(var.route_table_ids)
  vpc_endpoint_id = var.vpc_endpoint_id
  route_table_id  = var.route_table_ids[count.index]
}