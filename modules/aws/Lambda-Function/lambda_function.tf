# -------------------------------------------------------------------------------------
#
# Copyright (c) 2025, WSO2 LLC. (https://www.wso2.com) All Rights Reserved.
#
# WSO2 LLC. licenses this file to you under the Apache License,
# Version 2.0 (the "License"); you may not use this file except
# in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied. See the License for the
# specific language governing permissions and limitations
# under the License.
#
# --------------------------------------------------------------------------------------

# Lambda function
data "archive_file" "archive_lambda_function" {
  type        = "zip"
  source_file = "${var.lambda_function_source_dir}/${var.lambda_function_source_file}"
  output_path = "${var.lambda_function_source_dir}/${var.lambda_function_output_file}"
}

# Ignore: AVD-AWS-0066 (https://avd.aquasec.com/misconfig/aws/ec2/avd-aws-0017)
# Reason: Tracing logs adds a significant log volume/cost, Will be added on a per case basis or manually
# trivy:ignore:AVD-AWS-0066
resource "aws_lambda_function" "lambda_function" {
  filename         = data.archive_file.archive_lambda_function.output_path
  function_name    = join("-", [var.project, var.application, var.environment, var.region, var.lambda_function_name, "lambda-function"])
  role             = aws_iam_role.lambda_function_role.arn
  handler          = var.handler
  source_code_hash = data.archive_file.archive_lambda_function.output_base64sha256
  runtime          = var.runtime_version
  tags             = var.tags
}

# Ignore: AVD-AWS-0017 (https://avd.aquasec.com/misconfig/aws/ec2/avd-aws-0017)
# Reason: Variable KMS_KEY_ID is defined and can be used for explicit key encryption
# trivy:ignore:AVD-AWS-0017
resource "aws_cloudwatch_log_group" "lambda_function_log_group" {
  name              = "/aws/lambda/${aws_lambda_function.lambda_function.function_name}"
  retention_in_days = 30
  tags              = var.tags
  kms_key_id        = var.cloudwatch_log_group_kms_key_id

  depends_on = [aws_lambda_function.lambda_function]
}

# IAM policy to push to above cloudwatch log group
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

# IAM Policy
resource "aws_iam_policy" "lambda_function_policy" {
  name        = join("-", [var.project, var.application, var.environment, var.region, var.lambda_function_name, "lambda-function-cloudwatch-policy"])
  description = "IAM policy for the Lambda function to push logs to CloudWatch"
  policy      = data.aws_iam_policy_document.lambda_function_cloudwatch_role_policy.json

  tags = var.tags
}

# Attachment
resource "aws_iam_role_policy_attachment" "lambda_function_policy_attachment" {
  role       = aws_iam_role.lambda_function_role.name
  policy_arn = aws_iam_policy.lambda_function_policy.arn
}
