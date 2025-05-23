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

# Ignore: AVD-AWS-0098 (https://avd.aquasec.com/misconfig/aws/ec2/avd-aws-0098)
# Reason: Variable KMS_KEY_ID is defined and can be used for explicit key encryption
# trivy:ignore:AVD-AWS-0098
resource "aws_secretsmanager_secret" "secretsmanager_secret" {
  name                    = var.secret_name
  recovery_window_in_days = var.recovery_window_in_days

  kms_key_id = var.kms_key_id

  tags = var.tags
}

resource "aws_secretsmanager_secret_version" "secretsmanager_secret_version" {
  secret_id     = aws_secretsmanager_secret.secretsmanager_secret.id
  secret_string = var.secret_string

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_secretsmanager_secret_policy" "secretsmanager_secret_policy" {

  count = var.create_secret_reader_iam_policy ? 1 : 0

  secret_arn = aws_secretsmanager_secret.secretsmanager_secret.arn
  policy     = data.aws_iam_policy_document.iam_policy_document[0].json

  depends_on = [
    data.aws_iam_policy_document.iam_policy_document,
    aws_secretsmanager_secret.secretsmanager_secret
  ]
}
