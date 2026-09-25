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

output "instance_id" {
  value       = module.instance.ec2-instance-id
  description = "Target for aws ssm start-session"
}

output "security_group_id" {
  value       = module.security_group.security_group_id
  description = "Admit this wherever the bastion must reach (e.g. a cluster API security group, port 443)"
}

output "instance_role_arn" {
  value       = module.instance.ec2-instance-role-arn
  description = "The instance role: Session Manager permissions and nothing else. Do not grant it access to what the bastion reaches; operators use their own identity"
}

output "session_document_names" {
  value       = { for k, d in module.session_document : k => "${k}-session-manager-doc" }
  description = "Per-operator session documents: aws ssm start-session --target <instance_id> --document-name <this>"
}

output "session_log_group" {
  value = module.session_logs.log_group_name
}

output "association_names" {
  value       = compact([aws_ssm_association.operators.association_name, one(aws_ssm_association.caller[*].association_name)])
  description = "State Manager associations that configure the bastion; their run history is in Systems Manager"
}

output "suspension_schedule_names" {
  value       = [for s in aws_scheduler_schedule.suspension : s.name]
  description = "The stop and start schedules, when enabled"
}
