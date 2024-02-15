# -------------------------------------------------------------------------------------
#
# Copyright (c) 2024, WSO2 LLC. (http://www.wso2.com). All Rights Reserved.
#
# This software is the property of WSO2 LLC. and its suppliers, if any.
# Dissemination of any information or reproduction of any material contained
# herein in any form is strictly forbidden, unless permitted by WSO2 expressly.
# You may not alter or remove any copyright or other notice from copies of this content.
#
# --------------------------------------------------------------------------------------

# Ignore: AVD-AWS-0089 (https://avd.aquasec.com/misconfig/avd-aws-0090)
# Reason: Logging not required as of now for S3 Buckets, if required it will be added as a separate resource
# trivy:ignore:AVD-AWS-0089
resource "aws_s3_bucket" "s3_bucket" {
  bucket = join("-", [var.project, var.application, var.environment, var.region, "bucket"])

  tags = var.tags
}

resource "aws_s3_bucket_acl" "bucket_acl" {
  bucket = aws_s3_bucket.s3_bucket.id
  acl    = var.acl
}

# Ignore: AVD-AWS-0090 (https://avd.aquasec.com/misconfig/avd-aws-0090)
# Reason: Versioning has been enabled as a parameter with default value true
# trivy:ignore:AVD-AWS-0090
resource "aws_s3_bucket_versioning" "s3_bucket_versioning" {
  bucket  = aws_s3_bucket.s3_bucket.id
  enabled = var.versioning_enabled
}

# Ignore: AVD-AWS-0087 (https://avd.aquasec.com/misconfig/avd-aws-0087)
# Reason: There maybe occasions where public access is necessary, As such configured as parameter
# This has been configured as a parameter with default value true
# Ignore: AVD-AWS-0091 (https://avd.aquasec.com/misconfig/avd-aws-0091)
# Reason: There maybe occasions where public access is necessary, As such configured as parameter
# This has been configured as a parameter with default value true
# trivy:ignore:AVD-AWS-0091
# trivy:ignore:AVD-AWS-0087
resource "aws_s3_bucket_public_access_block" "s3_bucket_public_access_block" {
  bucket                  = aws_s3_bucket.s3_bucket.id
  block_public_acls       = var.block_public_acls
  restrict_public_buckets = var.restrict_public_buckets
}

resource "aws_s3_bucket_server_side_encryption_configuration" "s3_bucket_server_side_encryption_configuration" {
  bucket = aws_s3_bucket.s3_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = var.server_side_encryption.key_id
      sse_algorithm     = var.server_side_encryption.algorithm
    }
  }
}
