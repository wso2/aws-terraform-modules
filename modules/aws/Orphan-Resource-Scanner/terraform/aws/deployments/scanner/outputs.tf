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

output "lambda_function_name" {
  description = "Name of the deployed scanner Lambda function"
  value       = aws_lambda_function.scanner.function_name
}

output "lambda_function_arn" {
  description = "ARN of the scanner Lambda function"
  value       = aws_lambda_function.scanner.arn
}

output "lambda_execution_role_arn" {
  description = "ARN of the Lambda execution IAM role"
  value       = aws_iam_role.scanner_lambda.arn
}

output "report_bucket_name" {
  description = "Name of the S3 bucket where CSV reports are uploaded"
  value       = aws_s3_bucket.reports.id
}

output "report_bucket_arn" {
  description = "ARN of the S3 report bucket"
  value       = aws_s3_bucket.reports.arn
}

output "schedule_name" {
  description = "Name of the EventBridge Scheduler schedule"
  value       = aws_scheduler_schedule.weekly_scan.name
}

output "target_role_policy_json" {
  description = "Read-only IAM policy JSON to attach to the role you create in the target account (Account B). The role must also trust this hub account's Lambda execution role."
  value       = data.aws_iam_policy_document.allow_orphan_discovery.json
}

output "hub_lambda_execution_role_arn" {
  description = "ARN of the hub Lambda execution role - set this as the trusted principal on the target account role's trust policy."
  value       = aws_iam_role.scanner_lambda.arn
}
