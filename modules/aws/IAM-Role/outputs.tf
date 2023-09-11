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

output "iam_role_id" {
  value      = aws_iam_role.iam_role.id
  depends_on = [aws_iam_role.iam_role]
}
output "iam_role_arn" {
  value      = aws_iam_role.iam_role.arn
  depends_on = [aws_iam_role.iam_role]
}
output "iam_role_name" {
  value      = aws_iam_role.iam_role.name
  depends_on = [aws_iam_role.iam_role]
}
