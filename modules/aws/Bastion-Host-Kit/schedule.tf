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

# Suspend the bastion outside working hours, in step with whatever else the
# environment suspends. Stopping ends every session on it, which is the point of
# a suspend time; the associations bring users and tools back on start. Done with
# EventBridge Scheduler calling the EC2 API directly, so nothing has to be
# running for the resume to happen.

resource "aws_scheduler_schedule_group" "suspension" {
  count = var.suspension.enabled ? 1 : 0

  name = "${local.name_prefix}-bastion-suspension"
  tags = var.tags
}

data "aws_iam_policy_document" "suspension_assume_role" {
  count = var.suspension.enabled ? 1 : 0

  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["scheduler.amazonaws.com"]
    }
    condition {
      test     = "ArnLike"
      variable = "aws:SourceArn"
      values   = ["arn:aws:scheduler:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:schedule/${aws_scheduler_schedule_group.suspension[0].name}/*"]
    }
  }
}

resource "aws_iam_role" "suspension" {
  count = var.suspension.enabled ? 1 : 0

  name               = "${local.name_prefix}-bastion-suspension-iam-role"
  assume_role_policy = data.aws_iam_policy_document.suspension_assume_role[0].json
  tags               = var.tags
}

resource "aws_iam_role_policy" "suspension" {
  count = var.suspension.enabled ? 1 : 0

  name = "${local.name_prefix}-bastion-suspension-iam-policy"
  role = aws_iam_role.suspension[0].id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["ec2:StartInstances", "ec2:StopInstances"]
      Resource = module.instance.ec2-instance-arn
    }]
  })
}

resource "aws_scheduler_schedule" "suspension" {
  for_each = var.suspension.enabled ? {
    stop  = { expression = var.suspension.suspend_expression, action = "stopInstances" }
    start = { expression = var.suspension.resume_expression, action = "startInstances" }
  } : {}

  name       = "${local.name_prefix}-bastion-${each.key}"
  group_name = aws_scheduler_schedule_group.suspension[0].name

  schedule_expression          = each.value.expression
  schedule_expression_timezone = var.suspension.timezone

  flexible_time_window {
    mode = "OFF"
  }

  target {
    arn      = "arn:aws:scheduler:::aws-sdk:ec2:${each.value.action}"
    role_arn = aws_iam_role.suspension[0].arn
    # PascalCase member names: universal targets take the SDK shape.
    input = jsonencode({ InstanceIds = [module.instance.ec2-instance-id] })

    retry_policy {
      maximum_retry_attempts       = 3
      maximum_event_age_in_seconds = 3600
    }
  }
}
