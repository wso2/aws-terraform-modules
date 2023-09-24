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

resource "aws_vpc_endpoint_service" "vpc_endpoint_service" {
  acceptance_required        = var.acceptance_required
  network_load_balancer_arns = var.network_load_balancer_arns
  gateway_load_balancer_arns = var.gateway_load_balancer_arns
  allowed_principals         = var.allowed_principals
  tags                       = local.tags
  supported_ip_address_types = var.supported_ip_address_types
  private_dns_name           = var.private_dns_name
}
