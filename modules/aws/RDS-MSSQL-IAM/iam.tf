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

resource "aws_iam_instance_profile" "rds_instance_profile" {
  name = "AWSRDSCustomSQLServerInstanceProfile"
  role = aws_iam_role.rds_role.name
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "rds_role" {
  name               = "AWSRDSCustomSQLServerInstanceRole"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_role_policy_attachment" "rds_role_policy_attachment" {
  role       = aws_iam_role.rds_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonRDSCustomInstanceProfileRolePolicy"
}
