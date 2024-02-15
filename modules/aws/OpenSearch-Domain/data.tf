# -------------------------------------------------------------------------------------
#
# Copyright (c) 2024, WSO2 LLC. (http://www.wso2.com). All Rights Reserved.
#
# This software is the property of WSO2 LLC. and its suppliers, if any.
# Dissemination of any information or reproduction of any material contained
# herein in any form is strictly forbidden, unless permitted by WSO2 expressly.
# You may not alter or remove any copyright or other notice from copies of this content.
#
# --------------------------------------------------------------------------------------

data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "es_admins_policy_document" {
  statement {
    effect = "Allow"

    dynamic "principal" {
      for_each = var.principals
      content {
        type        = principal.value["type"]
        identifiers = principal.value["identifiers"]
      }
    }

    actions   = ["es:*"]
    resources = ["arn:aws:es:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:domain/${local.domain_name}/*"]
  }
}

data "aws_iam_policy_document" "es_cw_iam_policy_document" {
  count = var.log_publishing_options != null ? 1 : 0
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["es.amazonaws.com"]
    }

    actions = [
      "logs:PutLogEvents",
      "logs:PutLogEventsBatch",
      "logs:CreateLogStream",
    ]

    resources = ["arn:aws:logs:*"]
  }
}

resource "aws_cloudwatch_log_resource_policy" "es_cloudwatch_log_resource_policy" {
  count           = var.log_publishing_options != null ? 1 : 0
  policy_name     = "${local.domain_name}-cloudwatch-log-resource-policy"
  policy_document = data.aws_iam_policy_document.es_cw_iam_policy_document[0].json
}
