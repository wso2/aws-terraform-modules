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

resource "aws_secretsmanager_secret" "secret" {
  for_each = {
    for s in var.secrets : s.name => s
  }

  name        = each.value.name
  description = lookup(each.value, "description", null)
}

resource "aws_secretsmanager_secret_version" "secret_version" {
  for_each = {
    for s in var.secrets : s.name => s
  }

  secret_id     = aws_secretsmanager_secret.secret[each.key].id
  secret_string = jsonencode({ value = each.value.value })
}

data "aws_iam_policy_document" "assume_role" {
  for_each = {
    for binding in var.secret_access_bindings : "${binding.namespace}/${binding.serviceAccount}" => binding
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
      values   = ["system:serviceaccount:${each.value.namespace}:${each.value.serviceAccount}"]
    }
  }
}

resource "aws_iam_role" "iam_role" {
  for_each = data.aws_iam_policy_document.assume_role

  name               = replace("${each.key}-secret-reader", "/", "-")
  assume_role_policy = each.value.json
}

resource "aws_iam_policy" "access" {
  for_each = {
    for binding in var.secret_access_bindings : "${binding.namespace}/${binding.serviceAccount}" => binding
  }

  name = replace("${each.key}-secret-access", "/", "-")
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      for secret_name in each.value.secrets : {
        Effect   = "Allow"
        Action   = ["secretsmanager:GetSecretValue"]
        Resource = aws_secretsmanager_secret.secret[secret_name].arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "policy_attachment" {
  for_each = aws_iam_policy.access

  role       = aws_iam_role.iam_role[each.key].name
  policy_arn = each.value.arn
}

resource "local_file" "secrets_summary_yaml" {
  filename = "generated/secrets-summary.yaml"

  content = yamlencode({
    secrets = flatten([
      for binding in var.secret_access_bindings : [
        for secret_name in binding.secrets : {
          name    = aws_secretsmanager_secret.secret[secret_name].arn
          version = aws_secretsmanager_secret_version.secret_version[secret_name].version_id
          serviceAccount = {
            name      = binding.serviceAccount
            namespace = binding.namespace
            annotations = {
              "eks.amazonaws.com/role-arn" = aws_iam_role.iam_role["${binding.namespace}/${binding.serviceAccount}"].arn
            }
          }
        }
      ]
    ])
  })
}

