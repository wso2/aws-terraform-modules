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

output "autoscaling_group_id" {
  description = "The ID of the Auto Scaling group"
  value       = aws_autoscaling_group.autoscaling_group.id
}

output "autoscaling_group_arn" {
  description = "The ARN of the Auto Scaling group"
  value       = aws_autoscaling_group.autoscaling_group.arn
}

output "autoscaling_group_name" {
  description = "The name of the Auto Scaling group"
  value       = aws_autoscaling_group.autoscaling_group.name
}
