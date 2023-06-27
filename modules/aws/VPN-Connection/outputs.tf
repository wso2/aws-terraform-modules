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

output "vpn_connection_id" {
  value      = aws_vpn_connection.vpn_connection.id
  depends_on = [aws_vpn_connection.vpn_connection]
}
output "vpn_connection_arn" {
  value      = aws_vpn_connection.vpn_connection.arn
  depends_on = [aws_vpn_connection.vpn_connection]
}
output "vpn_connection_tunnel2_address" {
  value      = aws_vpn_connection.vpn_connection.tunnel2_address
  depends_on = [aws_vpn_connection.vpn_connection]
}
output "vpn_connection_tunnel1_address" {
  value      = aws_vpn_connection.vpn_connection.tunnel1_address
  depends_on = [aws_vpn_connection.vpn_connection]
}
