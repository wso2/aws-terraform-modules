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

output "secret_manager_iam_user_id" {
  value      = aws_iam_user.secrets_manager_user.id
  depends_on = []
}
output "secret_manager_iam_user_arn" {
  value      = aws_iam_user.secrets_manager_user.arn
  depends_on = []
}
