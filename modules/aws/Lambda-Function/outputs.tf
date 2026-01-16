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

output "iam_role_arn" {
  value       = aws_iam_role.lambda_function_role.arn
  description = "The ARN of the IAM role that the Lambda function assumes when it executes."
  depends_on  = [aws_iam_role.lambda_function_role]
}
output "function_arn" {
  value       = aws_lambda_function.lambda_function.arn
  description = "The ARN of the Lambda function."
  depends_on  = [aws_lambda_function.lambda_function]
}
output "function_name" {
  value       = aws_lambda_function.lambda_function.function_name
  description = "The name of the Lambda function."
  depends_on  = [aws_lambda_function.lambda_function]
}
output "iam_role_name" {
  value       = aws_iam_role.lambda_function_role.name
  description = "The name of the IAM role that the Lambda function assumes when it executes."
  depends_on  = [aws_iam_role.lambda_function_role]
}
