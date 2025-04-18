# -------------------------------------------------------------------------------------
#
# Copyright (c) 2024, WSO2 LLC. (http://www.wso2.com). All Rights Reserved.
#
# This software is the property of WSO2 LLC. and its suppliers, if any.
# Dissemination of any information or reproduction of any material contained
# herein in any form is strictly forbidden, unless permitted by WSO2 expressly.
# You may not alter or remove any copyright or other notice from copies of this content.
#
# --------------------------------------------------------------------------------------

resource "aws_iam_user" "iam_user" {
  name = join("-", [var.project, var.application, var.environment, var.region, "iam-user"])
  tags = var.tags
}

resource "aws_iam_user_policy_attachment" "iam_user_policy_attachment" {
  count      = length(var.policy_arns)
  policy_arn = var.policy_arns[count.index]
  user       = aws_iam_user.iam_user.name
}