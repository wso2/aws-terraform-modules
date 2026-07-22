# -------------------------------------------------------------------------------------
#
# Copyright (c) 2026, WSO2 LLC. (https://www.wso2.com) All Rights Reserved.
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

# Scanner Lambda function, its deployment package, exclusions parameter, and log
# group. The execution role and its policies live in iam.tf.

# Exclusion list. var.excluded_resource_ids is written here as JSON; the Lambda
# reads it at runtime and skips matching resources. Edit the conf and re-apply.
resource "aws_ssm_parameter" "exclusions" {
  name        = "/orphan-scanner/${local.environment}-${var.aws_region}/exclusions"
  description = "Resource IDs the orphan scanner should skip (JSON array)."
  type        = "String"
  value       = jsonencode(var.excluded_resource_ids)
  tags        = local.tags
}

data "archive_file" "scanner_lambda" {
  type        = "zip"
  source_file = "${path.module}/scripts/lambda_function.py"
  output_path = "${path.module}/scripts/scanner_lambda.zip"
}

resource "aws_lambda_function" "scanner" {
  filename         = data.archive_file.scanner_lambda.output_path
  function_name    = "${local.name_prefix}-lambda-function"
  role             = aws_iam_role.scanner_lambda.arn
  handler          = "lambda_function.lambda_handler"
  source_code_hash = data.archive_file.scanner_lambda.output_base64sha256
  runtime          = var.lambda_runtime
  timeout          = var.lambda_timeout
  memory_size      = var.lambda_memory_size
  tags             = local.tags

  environment {
    variables = {
      REPORT_BUCKET         = aws_s3_bucket.reports.id
      SENDER_EMAIL          = var.sender_email
      RECIPIENT_EMAILS      = var.recipient_emails
      SES_REGION            = coalesce(var.ses_region, var.aws_region)
      REGIONS               = var.regions
      SCAN_HUB_ACCOUNT      = tostring(var.scan_hub_account)
      HUB_ACCOUNT_NAME      = coalesce(var.hub_account_name, var.account_name)
      TARGET_ROLE_ARNS      = join(",", var.target_role_arns)
      EXCLUSIONS_PARAM_NAME = aws_ssm_parameter.exclusions.name
    }
  }
}

resource "aws_cloudwatch_log_group" "scanner_lambda" {
  name              = "/aws/lambda/${aws_lambda_function.scanner.function_name}"
  retention_in_days = 7
  tags              = local.tags
}
