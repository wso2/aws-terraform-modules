# -------------------------------------------------------------------------------------
#
# Copyright (c) 2026, WSO2 LLC. (https://www.wso2.com) All Rights Reserved.
#
# WSO2 LLC. licenses this file to you under the Apache License,
# Version 2.0 (the "License"); you may not use this file except
# in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied. See the License for the
# specific language governing permissions and limitations
# under the License.
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
