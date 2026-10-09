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

# Domain identity with Easy DKIM. Unlike the older aws_ses_domain_identity/aws_ses_domain_dkim
# pair, ownership is proven entirely via the 3 DKIM CNAME records below, so no separate
# _amazonses TXT verification token is needed for a DKIM-verified SESv2 domain identity.
resource "aws_sesv2_email_identity" "identity" {
  email_identity = var.domain_name
  tags           = var.tags

  dkim_signing_attributes {
    next_signing_key_length = var.dkim_signing_key_length
  }
}

# Custom MAIL FROM domain (SPF alignment), optional, off by default.
resource "aws_sesv2_email_identity_mail_from_attributes" "mail_from" {
  count = var.mail_from_subdomain != null ? 1 : 0

  email_identity         = aws_sesv2_email_identity.identity.email_identity
  mail_from_domain       = "${var.mail_from_subdomain}.${var.domain_name}"
  behavior_on_mx_failure = "USE_DEFAULT_VALUE"
}

# Bounce/complaint tracking, published to an existing alerting SNS topic that a deployment
# may already have. Feeds the same suppression list that
# sre-task-automation/toil/aws-ses-suppression-list manages.
resource "aws_sesv2_configuration_set" "configuration_set" {
  count = var.enable_event_destination ? 1 : 0

  configuration_set_name = "${local.name}-config-set"
  tags                   = var.tags
}

resource "aws_sesv2_configuration_set_event_destination" "sns" {
  count = var.enable_event_destination ? 1 : 0

  configuration_set_name = aws_sesv2_configuration_set.configuration_set[0].configuration_set_name
  event_destination_name = "${local.name}-bounce-complaint-sns"

  event_destination {
    enabled              = true
    matching_event_types = var.event_destination_matching_types

    sns_destination {
      topic_arn = var.sns_topic_arn
    }
  }
}
