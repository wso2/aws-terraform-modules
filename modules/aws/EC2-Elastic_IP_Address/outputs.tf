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

output "eip_public_ip" {
  description = "The public IP address of the EIP"
  value       = aws_eip.public_ip.public_ip
}
output "eip_allocation_id" {
  description = "The allocation ID of the EIP"
  value       = aws_eip.public_ip.id
}
output "eip_domain" {
  description = "The domain of the EIP"
  value       = aws_eip.public_ip.domain
}
output "eip_arn" {
  description = "The instance ID that the EIP is associated with"
  value       = aws_eip.public_ip.arn
}
