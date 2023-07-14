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

resource "aws_lb_target_group" "lb_target_group" {
  name        = join("-", [var.project, var.application, var.environment, var.region, "lb-tg"])
  target_type = var.target_type
  port        = var.port
  protocol    = var.protocol
  vpc_id      = var.vpc_id
}

# Create target group attachments for each
resource "aws_lb_target_group_attachment" "lb_target_group_attachment" {
  for_each          = var.target_group_attachments
  target_group_arn  = aws_lb_target_group.lb_target_group.arn
  target_id         = each.value.target_id
  availability_zone = each.value.availability_zone
  port              = each.value.port
  depends_on        = [aws_lb_target_group.lb_target_group]
}
