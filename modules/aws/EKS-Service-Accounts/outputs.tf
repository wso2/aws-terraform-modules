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

# Service account arns
output "service_account_arns" {
  value = {
    for item in var.service_accounts : item => aws_iam_role.iam_role[item].arn
  }
}
output "service_account_ids" {
  value = {
    for item in var.service_accounts : item => aws_iam_role.iam_role[item].id
  }
}
output "service_account_role_names" {
  value = {
    for item in var.service_accounts : item => aws_iam_role.iam_role[item].name
  }
}
