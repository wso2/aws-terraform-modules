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

output "vpc_endpoint_svc_arn" {
  value      = aws_vpc_endpoint_service.vpc_endpoint_service.arn
  depends_on = [aws_vpc_endpoint_service.vpc_endpoint_service]
}
output "vpc_endpoint_svc_id" {
  value      = aws_vpc_endpoint_service.vpc_endpoint_service.id
  depends_on = [aws_vpc_endpoint_service.vpc_endpoint_service]
}
output "vpc_endpoint_svc_name" {
  value      = aws_vpc_endpoint_service.vpc_endpoint_service.service_name
  depends_on = [aws_vpc_endpoint_service.vpc_endpoint_service]
}
output "vpc_endpoint_svc_type" {
  value      = aws_vpc_endpoint_service.vpc_endpoint_service.service_type
  depends_on = [aws_vpc_endpoint_service.vpc_endpoint_service]
}