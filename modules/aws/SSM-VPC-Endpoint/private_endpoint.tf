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
data "aws_vpc_endpoint_service" "ssm" {
  service = "ssm"
}

resource "aws_vpc_endpoint" "secrets_manager" {
  vpc_id            = var.vpc_id
  service_name      = data.aws_vpc_endpoint_service.ssm.service_name
  vpc_endpoint_type = "Interface"

  security_group_ids  = var.ssm_endpoint_security_group_ids
  subnet_ids          = var.subnet_ids
  private_dns_enabled = var.ssm_endpoint_private_dns_enabled
  tags                = local.tags

  depends_on = [
    data.aws_vpc_endpoint_service.ssm
  ]
}
