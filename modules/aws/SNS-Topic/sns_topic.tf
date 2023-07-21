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

resource "aws_sns_topic" "sns_topic" {
  name = join("-", [var.project, var.application, var.environment, var.region, var.topic_name])
  tags = var.tags
}

resource "aws_sns_topic_subscription" "subscription" {
  for_each = { for s in var.subscribers : s.endpoint => s }

  topic_arn = aws_sns_topic.sns_topic.arn
  protocol  = each.value.protocol
  endpoint  = each.value.endpoint
}
