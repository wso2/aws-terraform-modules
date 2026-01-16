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

output "backup_plan_id" {
  description = "The ID of the backup plan"
  value       = aws_backup_plan.this.id
}

output "backup_plan_arn" {
  description = "The ARN of the backup plan"
  value       = aws_backup_plan.this.arn
}

output "backup_plan_name" {
  description = "The name of the backup plan"
  value       = aws_backup_plan.this.name
}

output "backup_selection_id" {
  description = "The ID of the backup selection"
  value       = aws_backup_selection.this.id
}

output "backup_selection_name" {
  description = "The name of the backup selection"
  value       = aws_backup_selection.this.name
}

output "rule_count" {
  description = "Number of backup rules configured"
  value       = length(var.backup_rules)
}
