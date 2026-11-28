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
  name               = join("-", [var.project, var.application, var.environment, var.region, "lb-tg"])
  target_type        = var.target_type
  port               = var.port
  protocol           = var.protocol
  vpc_id             = var.vpc_id
  preserve_client_ip = var.preserve_client_ip
  tags               = var.tags

  dynamic "health_check" {
    for_each = var.health_check == null ? [] : [var.health_check]
    content {
      enabled             = health_check.value.enabled
      protocol            = coalesce(health_check.value.protocol, contains(["TCP", "HTTP", "HTTPS"], var.protocol) ? var.protocol : "TCP")
      port                = health_check.value.port
      path                = health_check.value.path
      interval            = health_check.value.interval
      timeout             = health_check.value.timeout
      healthy_threshold   = health_check.value.healthy_threshold
      unhealthy_threshold = health_check.value.unhealthy_threshold
      matcher             = health_check.value.matcher
    }
  }
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
