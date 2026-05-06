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

output "ip_set_id" {
  value      = aws_wafv2_ip_set.ip_set.id
  depends_on = [aws_wafv2_ip_set.ip_set]
}

output "ip_set_arn" {
  value      = aws_wafv2_ip_set.ip_set.arn
  depends_on = [aws_wafv2_ip_set.ip_set]
}
