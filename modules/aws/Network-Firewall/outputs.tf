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

output "firewall_id" {
  value      = aws_networkfirewall_firewall.networkfirewall_firewall.id
  depends_on = [aws_networkfirewall_firewall.networkfirewall_firewall]
}
output "firewall_arn" {
  value      = aws_networkfirewall_firewall.networkfirewall_firewall.arn
  depends_on = [aws_networkfirewall_firewall.networkfirewall_firewall]
}
output "firewall_endpoints_id" {
  value = flatten(aws_networkfirewall_firewall.networkfirewall_firewall.firewall_status[*].sync_states[*].attachment[*])[*].endpoint_id
}
output "firewall_endpoints_id_sync_states" {
  description = "Created Network Firewall states"
  value       = flatten(aws_networkfirewall_firewall.networkfirewall_firewall.firewall_status[*].sync_states[*])
}
output "firewall_name" {
  value      = aws_networkfirewall_firewall.networkfirewall_firewall.name
  depends_on = [aws_networkfirewall_firewall.networkfirewall_firewall]
}
