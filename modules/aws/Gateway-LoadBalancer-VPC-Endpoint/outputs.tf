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

output "vpc_endpoint_arn" {
  value      = aws_vpc_endpoint.gw_lb_vpc_endpoint.arn
  depends_on = [aws_vpc_endpoint.gw_lb_vpc_endpoint]
}
output "vpc_endpoint_id" {
  value      = aws_vpc_endpoint.gw_lb_vpc_endpoint.id
  depends_on = [aws_vpc_endpoint.gw_lb_vpc_endpoint]
}
output "vpc_endpoint_name" {
  value      = aws_vpc_endpoint.gw_lb_vpc_endpoint.service_name
  depends_on = [aws_vpc_endpoint.gw_lb_vpc_endpoint]
}
