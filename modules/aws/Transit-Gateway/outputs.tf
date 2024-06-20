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

output "transit_gateway_id" {
  value = aws_ec2_transit_gateway.ec2_transit_gateway.id
}
output "association_default_route_table_id" {
  value = aws_ec2_transit_gateway.ec2_transit_gateway.association_default_route_table_id
}
output "propagation_default_route_table_id" {
  value = aws_ec2_transit_gateway.ec2_transit_gateway.propagation_default_route_table_id
}
output "transit_gateway_arn" {
    value = aws_ec2_transit_gateway.ec2_transit_gateway.arn
}
