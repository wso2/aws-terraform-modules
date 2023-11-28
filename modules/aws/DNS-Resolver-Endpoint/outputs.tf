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

output "dns_resolver_endpoint_id" {
  value      = aws_route53_resolver_endpoint.route53_resolver_endpoint.id
  depends_on = [aws_route53_resolver_endpoint.route53_resolver_endpoint]
}
output "dns_resolver_endpoint_arn" {
  value      = aws_route53_resolver_endpoint.route53_resolver_endpoint.arn
  depends_on = [aws_route53_resolver_endpoint.route53_resolver_endpoint]
}
