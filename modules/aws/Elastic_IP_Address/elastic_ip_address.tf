# -------------------------------------------------------------------------------------
#
# Copyright (c) 2025, WSO2 LLC. (http://www.wso2.com). All Rights Reserved.
#
# This software is the property of WSO2 LLC. and its suppliers, if any.
# Dissemination of any information or reproduction of any material contained
# herein in any form is strictly forbidden, unless permitted by WSO2 expressly.
# You may not alter or remove any copyright or other notice from copies of this content.
#
# --------------------------------------------------------------------------------------

resource "aws_eip" "public_ip" {
  domain = var.eip_domain

  tags = local.eip_tags
}

resource "aws_shield_protection" "shield_protection" {
  count = var.shield_protection_enabled ? 1 : 0
  resource_arn = aws_eip.public_ip.arn
  name = local.eip_shield_protection_name

  tags = var.default_tags
}
