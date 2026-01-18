# -------------------------------------------------------------------------------------
#
# Copyright (c) 2023, WSO2 LLC. (http://www.wso2.com). All Rights Reserved.
#
# This software is the property of WSO2 LLC. and its suppliers, if any.
# Dissemination of any information or reproduction of any material contained
# herein in any form is strictly forbidden, unless permitted by WSO2 expressly.
# You may not alter or remove any copyright or other notice from copies of this content.
#
# --------------------------------------------------------------------------------------

# Ignore: AVD-AWS-0030 (https://avd.aquasec.com/misconfig/aws/ecr/avd-aws-0030/)
# Reason: Scanning on Image push should not be enabled by default and should be customizable per user requirement
# Ignore: AVD-AWS-0033 (https://avd.aquasec.com/misconfig/aws/ecr/avd-aws-0033/)
# Reason: While it has been enabled by default at the module level (check `encryption_type`)
# Further use of customer managed keys will be required per user requirement
# trivy:ignore:AVD-AWS-0030
# trivy:ignore:AVD-AWS-0033
resource "aws_ecr_repository" "ecr_repository" {
  name = join("-", [var.ecr_repository_abbreviation, var.ecr_repository_name])
  tags = var.tags

  image_tag_mutability = var.image_tag_mutability

  image_scanning_configuration {
    scan_on_push = var.scan_on_push # Custom parameter for AVD-AWS-0030
  }

  encryption_configuration {
    encryption_type = var.encryption_type # Custom parameter for AVD-AWS-0033
    kms_key         = var.encryption_type == "KMS" ? var.kms_key : null
  }
}

data "aws_iam_policy_document" "admin_policy" {
  count = length(var.external_admin_account_ids) > 0 ? 1 : 0

  statement {
    sid    = "External Admin policy"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = var.external_admin_account_ids
    }

    actions = [
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "ecr:BatchCheckLayerAvailability",
      "ecr:PutImage",
      "ecr:InitiateLayerUpload",
      "ecr:UploadLayerPart",
      "ecr:CompleteLayerUpload",
      "ecr:DescribeRepositories",
      "ecr:GetRepositoryPolicy",
      "ecr:ListImages",
      "ecr:DeleteRepository",
      "ecr:BatchDeleteImage",
      "ecr:SetRepositoryPolicy",
      "ecr:DeleteRepositoryPolicy",
    ]
  }
}

resource "aws_ecr_repository_policy" "admin_policy" {
  count      = length(var.external_admin_account_ids) > 0 ? 1 : 0
  repository = aws_ecr_repository.ecr_repository.name
  policy     = data.aws_iam_policy_document.admin_policy[0].json
}

data "aws_iam_policy_document" "pull_only_policy" {
  count = length(var.external_pull_only_account_ids) > 0 ? 1 : 0

  statement {
    sid    = "External Pull only policy"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = var.external_pull_only_account_ids
    }

    actions = [
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "ecr:BatchCheckLayerAvailability"
    ]
  }
}

resource "aws_ecr_repository_policy" "pull_only_policy" {
  count      = length(var.external_pull_only_account_ids) > 0 ? 1 : 0
  repository = aws_ecr_repository.ecr_repository.name
  policy     = data.aws_iam_policy_document.pull_only_policy[0].json
}
