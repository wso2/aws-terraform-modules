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

resource "aws_iam_role" "ecr_access_role" {
  name = join("-", [var.project, var.application, var.environment, var.region, "ecr-access-iam-role"])
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy" "ecr_access_policy" {
  name = join("-", [var.project, var.application, var.environment, var.region, "ecr-access-iam-policy"])
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "imagebuilder:GetComponent",
          "imagebuilder:GetContainerRecipe",
          "ecr:GetAuthorizationToken",
          "ecr:BatchGetImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:PutImage",
          "ecr:CreateRepository",
          "ecr:DeleteRepository",
          "ecr:DescribeRepositories",
          "ecr:BatchDeleteImage"
        ],
        Effect   = "Allow",
        Resource = "*"
      }
    ]
  })
}

# Attach the IAM policy to the IAM role
resource "aws_iam_role_policy_attachment" "ecr_role_policy_attachment" {
  role       = aws_iam_role.ecr_access_role.name
  policy_arn = aws_iam_policy.ecr_access_policy.arn
}
