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

resource "aws_cloudwatch_event_rule" "rule" {
  name                = var.name
  description         = var.description
  event_pattern       = var.event_pattern
  schedule_expression = var.schedule_expression
  is_enabled          = var.is_enabled
  role_arn            = var.role_arn
  tags                = var.tags
}
