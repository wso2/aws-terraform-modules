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

output "identity_arn" {
  description = "ARN of the SES domain identity"
  value       = aws_sesv2_email_identity.identity.arn
}

output "dkim_tokens" {
  description = "3 DKIM CNAME record hosts to create at <token>._domainkey.<domain_name> (each pointing to <token>.dkim.amazonses.com) to verify the domain and enable signing"
  value       = aws_sesv2_email_identity.identity.dkim_signing_attributes[0].tokens
}

output "mail_from_domain" {
  description = "Custom MAIL FROM domain, if enabled (needs an MX and a permissive SPF TXT record in DNS)"
  value       = try(aws_sesv2_email_identity_mail_from_attributes.mail_from[0].mail_from_domain, null)
}

output "smtp_hostname" {
  description = "SES SMTP endpoint hostname for this region"
  value       = "email-smtp.${var.aws_region}.amazonaws.com"
}

output "smtp_username" {
  description = "SES SMTP username (the IAM access key ID)"
  value       = aws_iam_access_key.smtp.id
}

output "smtp_password" {
  description = "SES SMTP password, derived from the IAM secret access key"
  value       = data.external.smtp_password.result.password
  sensitive   = true
}
