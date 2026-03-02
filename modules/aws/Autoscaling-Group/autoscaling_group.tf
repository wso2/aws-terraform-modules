# -------------------------------------------------------------------------------------
#
# Copyright (c) 2026, WSO2 LLC. (http://www.wso2.com). All Rights Reserved.
#
# This software is the property of WSO2 LLC. and its suppliers, if any.
# Dissemination of any information or reproduction of any material contained
# herein in any form is strictly forbidden, unless permitted by WSO2 expressly.
# You may not alter or remove any copyright or other notice from copies of this content.
#
# --------------------------------------------------------------------------------------

resource "aws_autoscaling_group" "autoscaling_group" {
  name                      = join("-", [var.project, var.application, var.environment, var.region, var.name, "asg"])
  max_size                  = var.max_size
  min_size                  = var.min_size
  desired_capacity          = var.desired_size
  vpc_zone_identifier       = var.vpc_zone_identifier
  target_group_arns         = var.target_group_arns
  health_check_type         = var.health_check_type
  health_check_grace_period = var.health_check_grace_period
  default_cooldown          = var.default_cooldown

  launch_template {
    id      = var.launch_template_id
    version = "$Latest"
  }

  termination_policies = var.termination_policies
  wait_for_capacity_timeout = var.wait_for_capacity_timeout
  protect_from_scale_in = var.protect_from_scale_in

  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = var.min_healthy_percentage
      instance_warmup = 600
    }
    triggers = ["tag"]
  }

  dynamic "tag" {
    for_each = var.tags
    content {
      key                 = tag.value.key
      value               = tag.value.value
      propagate_at_launch = tag.value.propagate_at_launch
    }
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [desired_capacity]
  }
}
