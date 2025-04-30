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

output "service_account_iam_role_arns" {
  value = {
    for binding in var.secret_access_bindings :
    "${binding.namespace}/${binding.serviceAccount}" => aws_iam_role.iam_role["${binding.namespace}/${binding.serviceAccount}"].arn
  }
  description = "IAM role ARNs mapped by namespace/service account"
}
output "service_account_iam_role_names" {
  value = {
    for binding in var.secret_access_bindings :
    "${binding.namespace}/${binding.serviceAccount}" => aws_iam_role.iam_role["${binding.namespace}/${binding.serviceAccount}"].name
  }
  description = "IAM role Names mapped by namespace/service account"
}
