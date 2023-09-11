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


output "iam_policy_id" {
  value      = aws_iam_policy.iam_policy.id
  depends_on = [aws_iam_policy.iam_policy]
}
output "iam_policy_arn" {
  value      = aws_iam_policy.iam_policy.arn
  depends_on = [aws_iam_policy.iam_policy]
}
output "iam_policy_name" {
  value      = aws_iam_policy.iam_policy.name
  depends_on = [aws_iam_policy.iam_policy]
}
