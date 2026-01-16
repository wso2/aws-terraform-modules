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

resource "aws_backup_plan" "this" {
  name = "${var.project}-${var.service_name}-backup-${var.environment}-${var.region}-plan"

  dynamic "rule" {
    for_each = var.backup_rules
    content {
      rule_name         = "${var.project}-${var.service_name}-${rule.value.name}-${var.environment}-${var.region}"
      target_vault_name = var.backup_vault_name
      schedule          = rule.value.schedule
      start_window      = lookup(rule.value, "start_window", 60)
      completion_window = lookup(rule.value, "completion_window", 120)

      lifecycle {
        delete_after       = rule.value.retention_days
        cold_storage_after = rule.value.cold_storage_days
      }

      dynamic "copy_action" {
        for_each = lookup(rule.value, "copy_actions", [])
        content {
          destination_vault_arn = copy_action.value.destination_vault_arn

          lifecycle {
            delete_after       = lookup(copy_action.value, "retention_days", rule.value.retention_days)
            cold_storage_after = lookup(copy_action.value, "cold_storage_days", null)
          }
        }
      }
    }
  }

  tags = merge(
    var.tags,
    {
      Name      = "${var.project}-${var.service_name}-backup-${var.environment}-${var.region}-plan"
      Service   = var.service_name
      ManagedBy = "terraform"
    }
  )
}

resource "aws_backup_selection" "this" {
  name         = "${var.project}-${var.service_name}-backup-${var.environment}-${var.region}-selection"
  plan_id      = aws_backup_plan.this.id
  iam_role_arn = var.backup_iam_role_arn

  selection_tag {
    type  = "STRINGEQUALS"
    key   = var.selection_tag_key
    value = var.selection_tag_value
  }
}
