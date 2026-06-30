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
# IAM roles, policies, and attachments for the scanner Lambda and the scheduler.
# Policy documents are defined in data.tf.
# -------------------------------------------------------------------------------------

# --- Lambda execution role -----------------------------------------------------------

resource "aws_iam_role" "scanner_lambda" {
  name               = "${local.name_prefix}-lambda-iam-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
  tags               = local.tags
}

# CloudWatch Logs write permission for the function.
resource "aws_iam_policy" "scanner_lambda_logging" {
  name        = "${local.name_prefix}-lambda-cloudwatch-policy"
  description = "IAM policy for the Lambda function to push logs to CloudWatch"
  policy      = data.aws_iam_policy_document.lambda_logging.json
  tags        = local.tags
}

resource "aws_iam_role_policy_attachment" "scanner_lambda_logging" {
  role       = aws_iam_role.scanner_lambda.name
  policy_arn = aws_iam_policy.scanner_lambda_logging.arn
}

# --- Least-privilege policies on the Lambda role (defined in local.lambda_policies) ---

resource "aws_iam_policy" "lambda" {
  for_each = local.lambda_policies

  name   = "${local.service_id}-${each.key}-${local.location_id}-iam-policy"
  policy = each.value
  tags   = local.tags
}

resource "aws_iam_role_policy_attachment" "lambda" {
  for_each = local.lambda_policies

  role       = aws_iam_role.scanner_lambda.name
  policy_arn = aws_iam_policy.lambda[each.key].arn
}

# --- EventBridge Scheduler execution role -------------------------------------------

resource "aws_iam_role" "scheduler" {
  name               = "${local.service_id}-scheduler-${local.location_id}-iam-role"
  assume_role_policy = data.aws_iam_policy_document.scheduler_assume_role.json
  tags               = local.tags
}

resource "aws_iam_policy" "scheduler_invoke" {
  name   = "${local.service_id}-sched-invoke-${local.location_id}-iam-policy"
  policy = data.aws_iam_policy_document.scheduler_invoke_lambda.json
  tags   = local.tags
}

resource "aws_iam_role_policy_attachment" "scheduler_invoke" {
  role       = aws_iam_role.scheduler.name
  policy_arn = aws_iam_policy.scheduler_invoke.arn
}
