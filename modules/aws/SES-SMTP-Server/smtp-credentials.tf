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

# Dedicated, non-console IAM user whose access key is only ever used to derive an SES SMTP
# password below — never used directly as an API credential.
# Ignore:AVD-AWS-0143 (https://avd.aquasec.com/misconfig/aws/ec2/AWS-0143)
# Reason: IAM Policy attached below
# trivy:ignore:AVD-AWS-0143
resource "aws_iam_user" "smtp" {
  name = "${local.name}-user"
  path = "/"
  tags = var.tags
}

# Scoped to this identity only (not Resource = "*"), and to the two actions an SMTP client
# actually needs.
resource "aws_iam_user_policy" "smtp" {
  name = "${local.name}-send-policy"
  user = aws_iam_user.smtp.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["ses:SendRawEmail", "ses:SendEmail"]
        Resource = aws_sesv2_email_identity.this.arn
      }
    ]
  })
}

resource "aws_iam_access_key" "smtp" {
  user = aws_iam_user.smtp.name
}

# SES SMTP auth needs a password derived from the IAM secret access key (AWS's published
# HMAC-SHA256 signing-key derivation, seeded with the literal string "SendRawEmail") — there is
# no Terraform-native function for this, and no AWS API returns it, so it's computed locally via
# this external data source. See:
# https://docs.aws.amazon.com/ses/latest/dg/smtp-credentials.html#smtp-credentials-convert
# The raw secret access key is only ever read here; it is not exposed as a module output.
data "external" "smtp_password" {
  program = ["python3", "${path.module}/scripts/derive_smtp_password.py"]
  query = {
    secret_access_key = aws_iam_access_key.smtp.secret
    region            = var.aws_region
  }
}
