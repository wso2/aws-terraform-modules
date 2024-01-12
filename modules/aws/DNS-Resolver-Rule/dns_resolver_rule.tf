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

resource "aws_route53_resolver_rule" "route53_resolver_rule" {
  domain_name          = var.domain_name
  name                 = var.name
  rule_type            = var.rule_type
  resolver_endpoint_id = var.resolver_endpoint_id

  dynamic "target_ip" {
    for_each = var.target_ips
    content {
      ip = target_ip.value
    }
  }

  tags = var.tags
}

resource "aws_route53_resolver_rule_association" "route53_resolver_rule_association" {
  resolver_rule_id = aws_route53_resolver_rule.route53_resolver_rule.id
  vpc_id           = var.vpc_id
}
