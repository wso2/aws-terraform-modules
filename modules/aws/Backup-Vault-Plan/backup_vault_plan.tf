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

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["backup.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}
resource "aws_iam_role" "backup_role" {
  name               = join("-", [var.project, var.application, var.environment, var.region, "backup-vault-role"])
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_role_policy_attachment" "backup_role_policy_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForBackup"
  role       = aws_iam_role.backup_role.name
}

resource "aws_backup_plan" "backup_plan" {
  name = var.backup_plan_name

  rule {
    rule_name                = var.rule_name
    target_vault_name        = var.vault_name
    schedule                 = "cron(${var.schedule})"
    enable_continuous_backup = var.enable_continuous_backup

    start_window      = var.start_window
    completion_window = var.completion_window

    lifecycle {
      cold_storage_after                        = var.cold_storage_after
      delete_after                              = var.delete_after
      opt_in_to_archive_for_supported_resources = var.opt_in_to_archive_for_supported_resource
    }
  }
}

resource "aws_backup_selection" "backup_selection" {
  iam_role_arn = aws_iam_role.backup_role.arn
  name         = var.backup_selection_name
  plan_id      = aws_backup_plan.backup_plan.id

  resources = var.backup_resources
}