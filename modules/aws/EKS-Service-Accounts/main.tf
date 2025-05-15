# -------------------------------------------------------------------------------------
#
# Copyright (c) 2025, WSO2 LLC. (http://www.wso2.com). All Rights Reserved.
#
# This software is the property of WSO2 LLC. and its suppliers, if any.
# Dissemination of any information or reproduction of any material contained
# herein in any form is strictly forbidden, unless permitted by WSO2 expressly.
# You may not alter or remove any copyright or other notice from copies of this content.
#
# --------------------------------------------------------------------------------------

data "aws_iam_policy_document" "assume_role" {
  for_each = {
    for item in var.service_accounts : item => true
  }

  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = ["arn:aws:iam::${var.aws_account_id}:oidc-provider/${var.oidc_provider_url}"]
    }

    condition {
      test     = "StringEquals"
      variable = "${var.oidc_provider_url}:sub"
      values   = ["system:serviceaccount:${var.namespace}:${each.key}"]
    }
  }
}

resource "aws_iam_role" "iam_role" {
  for_each = {
    for item in var.service_accounts : item => true
  }

  name               = substr("${local.shortened_cluster_name}-${var.namespace}-${each.key}", 0, 64)
  assume_role_policy = data.aws_iam_policy_document.assume_role[each.key].json
}
