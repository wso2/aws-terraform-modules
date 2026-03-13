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

output "subnet_ids" {
  value      = { for k, s in aws_subnet.subnet : k => s.id }
  depends_on = [aws_subnet.subnet]
}
output "route_table_ids" {
  value      = { for k, rt in aws_route_table.route_table : k => rt.id }
  depends_on = [aws_route_table.route_table]
}
output "subnet_names" {
  value = { for k, v in local.subnet_map : k => join("-", [v.name_prefix, "snet"]) }
}
output "subnet_cidr_blocks" {
  value      = { for k, s in aws_subnet.subnet : k => s.cidr_block }
  depends_on = [aws_subnet.subnet]
}

# Single-value aliases (first subnet) retained for backwards compatibility
output "subnet_id" {
  value      = values(aws_subnet.subnet)[0].id
  depends_on = [aws_subnet.subnet]
}
output "route_table_id" {
  value      = values(aws_route_table.route_table)[0].id
  depends_on = [aws_route_table.route_table]
}
output "subnet_name" {
  value = values(local.subnet_map)[0].name_prefix
}
output "subnet_cidr_block" {
  value      = values(aws_subnet.subnet)[0].cidr_block
  depends_on = [aws_subnet.subnet]
}
