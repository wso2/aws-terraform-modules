# -------------------------------------------------------------------------------------
#
# Copyright (c) 2026, WSO2 LLC. (http://www.wso2.com). All Rights Reserved.
#
# This software is the property of WSO2 LLC. and its suppliers, if any.
# Dissemination of any information or reproduction of any material contained
# herein in any form is strictly forbidden, unless permitted by WSO2 expressly.
# You may not alter or remove any copyright or other notice from copies of this content.
#
# --------------------------------------------------------------------------------------

resource "aws_route53_zone" "public_route53_zone" {
  name = var.dns_zone_name
  tags = var.tags
}

# Enable DNSSEC signing
resource "aws_route53_key_signing_key" "public_route53_zone" {
  hosted_zone_id             = aws_route53_zone.public_route53_zone.id
  key_management_service_arn = aws_kms_key.dnssec.arn
  name                       = "dnssec-ksk"
}

resource "aws_route53_hosted_zone_dnssec" "public_route53_zone" {
  hosted_zone_id = aws_route53_key_signing_key.public_route53_zone.hosted_zone_id

  depends_on = [aws_route53_key_signing_key.public_route53_zone]
}

# KMS key for DNSSEC — must be in us-east-1
resource "aws_kms_key" "dnssec" {
  provider                 = aws.us_east_1 # DNSSEC KMS keys must be in us-east-1
  customer_master_key_spec = "ECC_NIST_P256"
  deletion_window_in_days  = 7
  key_usage                = "KEY_AGREEMENT"
  policy = jsonencode({
    Statement = [
      {
        Action    = ["kms:DescribeKey", "kms:GetPublicKey", "kms:Sign"],
        Effect    = "Allow"
        Principal = { Service = "dnssec-route53.amazonaws.com" }
        Resource  = "*"
      },
      {
        Action    = "kms:*"
        Effect    = "Allow"
        Principal = { AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root" }
        Resource  = "*"
      }
    ]
    Version = "2012-10-17"
  })
  tags = var.tags
}
