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

data "archive_file" "archive_lambda_function" {
  type        = "zip"
  source_file = "${var.lambda_function_source_dir}/${var.lambda_function_source_file}"
  output_path = "${var.lambda_function_source_dir}/${var.lambda_function_output_file}"
}

resource "aws_lambda_function" "lambda_function" {
  filename         = data.archive_file.archive_lambda_function.output_path
  function_name    = join("-", [var.lambda_function_abbreviation, var.lambda_function_name])
  role             = aws_iam_role.lambda_function_role.arn
  handler          = var.handler
  source_code_hash = data.archive_file.archive_lambda_function.output_base64sha256
  runtime          = var.runtime_version
  tags             = var.tags
}

resource "aws_cloudwatch_log_group" "lambda_function_log_group" {
  name              = "/aws/lambda/${aws_lambda_function.lambda_function.function_name}"
  retention_in_days = 30
  tags              = var.tags

  depends_on = [aws_lambda_function.lambda_function]
}

data "aws_iam_policy_document" "lambda_function_cloudwatch_role_policy" {
  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
    resources = [
      aws_cloudwatch_log_group.lambda_function_log_group.arn,
      "${aws_cloudwatch_log_group.lambda_function_log_group.arn}:*",
    ]
  }
}

resource "aws_iam_policy" "lambda_function_policy" {
  name        = join("-", [var.iam_policy_abbreviation, var.iam_policy_name])
  description = "IAM policy for the Lambda function to push logs to CloudWatch"
  policy      = data.aws_iam_policy_document.lambda_function_cloudwatch_role_policy.json
  tags        = var.tags
}

resource "aws_iam_role_policy_attachment" "lambda_function_policy_attachment" {
  role       = aws_iam_role.lambda_function_role.name
  policy_arn = aws_iam_policy.lambda_function_policy.arn
}
