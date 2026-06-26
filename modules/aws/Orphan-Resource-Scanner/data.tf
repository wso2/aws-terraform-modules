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

# Lambda execution role trust policy.
data "aws_iam_policy_document" "lambda_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

# Allow the function to write its own CloudWatch log stream.
data "aws_iam_policy_document" "lambda_logging" {
  statement {
    sid    = "WriteScannerLambdaLogs"
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
    resources = [
      aws_cloudwatch_log_group.scanner_lambda.arn,
      "${aws_cloudwatch_log_group.scanner_lambda.arn}:*",
    ]
  }
}

# Write reports to S3.
data "aws_iam_policy_document" "allow_s3_write" {
  statement {
    sid       = "WriteOrphanReportsToS3"
    effect    = "Allow"
    actions   = ["s3:PutObject"]
    resources = ["${aws_s3_bucket.reports.arn}/*"]
  }
}

# Send report email via SES.
data "aws_iam_policy_document" "allow_ses_send" {
  statement {
    sid       = "SendOrphanReportEmail"
    effect    = "Allow"
    actions   = ["ses:SendEmail", "ses:SendRawEmail"]
    resources = ["*"]
  }
}

# Read-only discovery actions. Used for the hub's own scan and emitted via the
# target_role_policy_json output for target-account roles.
data "aws_iam_policy_document" "allow_orphan_discovery" {
  statement {
    sid       = "ReadOnlyOrphanDiscovery"
    effect    = "Allow"
    actions   = local.discovery_actions
    resources = ["*"]
  }
}

# Allow assuming the configured target_role_arns. Only created when a target exists.
data "aws_iam_policy_document" "allow_assume_target_role" {
  count = local.has_target ? 1 : 0

  statement {
    sid       = "AssumeTargetScannerRoles"
    effect    = "Allow"
    actions   = ["sts:AssumeRole"]
    resources = local.effective_target_role_arns
  }
}

# Read the exclusions parameter from SSM Parameter Store.
data "aws_iam_policy_document" "allow_read_exclusions_param" {
  statement {
    sid       = "ReadExclusionsParameter"
    effect    = "Allow"
    actions   = ["ssm:GetParameter"]
    resources = [aws_ssm_parameter.exclusions.arn]
  }
}

# EventBridge Scheduler execution role trust policy.
data "aws_iam_policy_document" "scheduler_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["scheduler.amazonaws.com"]
    }
  }
}

# Allow the scheduler role to invoke the scanner Lambda.
data "aws_iam_policy_document" "scheduler_invoke_lambda" {
  statement {
    sid       = "InvokeOrphanScannerLambda"
    effect    = "Allow"
    actions   = ["lambda:InvokeFunction"]
    resources = [aws_lambda_function.scanner.arn]
  }
}
