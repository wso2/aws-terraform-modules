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

# Session Manager
resource "aws_iam_policy" "session_manager_policy" {
  count = var.enable_session_manager == true ? 1 : 0
  name  = join("-", [var.project, var.application, var.environment, var.region, "ec2-session-manager-iam-policy"])
  policy = jsonencode({
    Statement = [{
      Action = [
        "ssm:UpdateInstanceInformation",
        "ssmmessages:CreateControlChannel",
        "ssmmessages:CreateDataChannel",
        "ssmmessages:OpenControlChannel",
        "ssmmessages:OpenDataChannel"
      ]
      Effect   = "Allow"
      Resource = "*"
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role" "iam_role" {
  name = join("-", [var.project, var.application, var.environment, var.region, "ec2-iam-role"])

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
      {
          "Effect": "Allow",
          "Principal": {
              "Service": ["ec2.amazonaws.com", "ssm.amazonaws.com"]
          },
          "Action": "sts:AssumeRole"
      }
  ]
}
POLICY
  tags               = var.tags
}


resource "aws_iam_instance_profile" "iam_instance_profile" {
  name = join("-", [var.project, var.application, var.environment, var.region, "ec2-instance-profile"])
  role = aws_iam_role.iam_role.name

  depends_on = [aws_iam_role.iam_role]
}

resource "aws_iam_role_policy_attachment" "instance_connect" {
  count      = var.enable_instance_connect == true ? 1 : 0
  role       = aws_iam_role.iam_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "session_manager" {
  count      = var.enable_session_manager == true ? 1 : 0
  role       = aws_iam_role.iam_role.name
  policy_arn = aws_iam_policy.session_manager_policy[0].arn
}
