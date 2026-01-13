# -------------------------------------------------------------------------------------
#
# Copyright (c) 2025, WSO2 LLC. (https://www.wso2.com) All Rights Reserved.
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
