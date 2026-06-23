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

# Fill in every <PLACEHOLDER> below before running env-create.sh.
#
# Deploy the scanner:
#   bash env-create.sh -c terraform/aws/conf/rnd/orphan-scanner.rnd.conf.tfvars -l scanner


# ---------------------------------------------------------------------------
# Scanner deployment settings
# ---------------------------------------------------------------------------

project                = "aws-orphan-scanner" # used as a resource-name prefix
deployment_environment = "rnd"                # e.g. rnd, staging, prod

aws_region     = "us-east-1" # where the scanner resources are deployed
lambda_runtime = "python3.12"

# Friendly label for the hub account (tagging only) and the S3 bucket that stores
# the CSV reports. report_bucket_name must be globally unique.
account_name       = "<ACCOUNT_NAME>"
report_bucket_name = "<GLOBALLY_UNIQUE_REPORT_BUCKET_NAME>"

# sender_email must be SES-verified in aws_region before apply. In the SES
# sandbox, every recipient must be verified too.
sender_email     = "<SENDER_EMAIL>"
recipient_emails = "<RECIPIENT_EMAIL>" # comma-separated for multiple

# Leave "" to auto-discover all enabled regions per account (recommended).
# Set a comma-separated list to restrict scanning, e.g. "us-east-1,eu-west-1".
regions = ""

# EXCLUSIONS - resource IDs the scanner must never report. Add an ID and re-apply
# to exclude it; remove it and re-apply to undo. Stored in SSM Parameter Store.
excluded_resource_ids = [
  # "vol-0abc1234567890def",   # example: keep - DR snapshot source
  # "eipalloc-0abc1234567890", # example: keep - reserved for failover
]


# ---------------------------------------------------------------------------
# ACCOUNTS TO SCAN
#
# The scanner runs from a single hub account and supports two modes:
#   - Scan the hub itself:       set scan_hub_account = true
#   - Scan other accounts:       add one cross-account role ARN per target
# ---------------------------------------------------------------------------

# Scan the hub account (the one this is deployed into) with the Lambda's own creds.
scan_hub_account = true
hub_account_name = "<HUB_ACCOUNT_DISPLAY_NAME>" # shown in the report

# Read-only role ARNs to scan. Create each role out-of-band in the target
# account; it must trust this hub's Lambda role (output: hub_lambda_execution_role_arn)
# and grant the read policy (output: target_role_policy_json).
target_role_arns = [
  # "arn:aws:iam::<TARGET_ACCOUNT_ID>:role/orphan-scanner-readonly",
]
