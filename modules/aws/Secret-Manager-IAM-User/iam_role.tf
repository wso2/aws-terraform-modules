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

# Ignore:AVD-AWS-0143 (https://avd.aquasec.com/misconfig/aws/ec2/AWS-0143)
# Reason: IAM Policy attached below
# trivy:ignore:AVD-AWS-0143
resource "aws_iam_user" "secrets_manager_user" {
  name = join("-", [var.project, var.application, var.environment, var.region, "secret-manager-iam-user"])
  tags = var.tags
}

# Attach the IAM policy to the IAM user
resource "aws_iam_user_policy_attachment" "secrets_manager_user_policy_attachment" {
  user       = aws_iam_user.secrets_manager_user.name
  policy_arn = "arn:aws:iam::aws:policy/SecretsManagerReadWrite"

  depends_on = [
    aws_iam_user.secrets_manager_user
  ]
}
