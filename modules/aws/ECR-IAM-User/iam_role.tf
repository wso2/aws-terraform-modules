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

# Ignore: AVD-AWS-0143 (https://avd.aquasec.com/misconfig/aws/iam/avd-aws-0143/)
# Reason: Ignoring as this user is made for a specific access only and access doesn't need to be shared among
# multiple users.
# trivy:ignore:AVD-AWS-0143
resource "aws_iam_user" "ecr_access_user" {
  name = join("-", [var.project, var.application, var.environment, var.region, "ecr-access-iam-user"])
  tags = var.tags
}

# Ignore: AVD-AWS-0057 (https://avd.aquasec.com/misconfig/aws/iam/avd-aws-0057/)
# Reason: This if for an Admin user with access to all ECR resources. Hence, the wildcard is required.
# trivy:ignore:AVD-AWS-0057
resource "aws_iam_policy" "ecr_access_policy" {
  name = join("-", [var.project, var.application, var.environment, var.region, "ecr-access-iam-policy"])
  tags = var.tags
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

# Attach the IAM policy to the IAM user
resource "aws_iam_user_policy_attachment" "ecr_user_policy_attachment" {
  user       = aws_iam_user.ecr_access_user.name
  policy_arn = aws_iam_policy.ecr_access_policy.arn
}
