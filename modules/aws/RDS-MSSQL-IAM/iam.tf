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