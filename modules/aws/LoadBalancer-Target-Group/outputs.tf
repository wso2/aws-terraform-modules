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

output "loadbalancer_target_group_id" {
  value      = aws_lb_target_group.lb_target_group.id
  depends_on = [aws_lb_target_group.lb_target_group]
}
output "loadbalancer_target_group_arn" {
  value      = aws_lb_target_group.lb_target_group.arn
  depends_on = [aws_lb_target_group.lb_target_group]
}
