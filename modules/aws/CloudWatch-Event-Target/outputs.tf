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

output "id" {
  description = "The unique identifier for the target"
  value       = aws_cloudwatch_event_target.target.id
}

output "target_id" {
  description = "The unique target assignment ID"
  value       = aws_cloudwatch_event_target.target.target_id
}
