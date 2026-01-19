# -------------------------------------------------------------------------------------
#
# Copyright (c) 2025, WSO2 LLC. (https://www.wso2.com) All Rights Reserved.
#
# WSO2 LLC. licenses this file to you under the Apache License,
# Version 2.0 (the "License"); you may not use this file except
# in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied. See the License for the
# specific language governing permissions and limitations
# under the License.
#
# --------------------------------------------------------------------------------------

# Ignore: AVD-AWS-0089 (https://avd.aquasec.com/misconfig/avd-aws-0090)
# Reason: Logging not required as of now for S3 Buckets, if required it will be added as a separate resource
# trivy:ignore:AVD-AWS-0089
resource "aws_s3_bucket" "s3_bucket" {
  bucket        = join("-", [var.project, var.application, var.environment, var.region, "bucket"])
  force_destroy = var.force_destroy
  tags          = var.tags
}

# Ignore: AVD-AWS-0090 (https://avd.aquasec.com/misconfig/avd-aws-0090)
# Reason: Versioning has been enabled as a parameter with default value true
# trivy:ignore:AVD-AWS-0090
resource "aws_s3_bucket_versioning" "s3_bucket_versioning" {
  bucket = aws_s3_bucket.s3_bucket.id
  versioning_configuration {
    status = var.versioning_enabled ? "Enabled" : "Suspended"
  }
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
  block_public_policy     = var.block_public_policy
  ignore_public_acls      = var.ignore_public_acls
  restrict_public_buckets = var.restrict_public_buckets
}

# Ignore: AVD-AWS-0132 (https://avd.aquasec.com/misconfig/aws/ec2/avd-aws-00132)
# Reason: Variable KMS_KEY_ID is defined and can be used for explicit key encryption
# trivy:ignore:AVD-AWS-0132
resource "aws_s3_bucket_server_side_encryption_configuration" "s3_bucket_server_side_encryption_configuration" {
  bucket = aws_s3_bucket.s3_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = var.server_side_encryption.kms_key_id
      sse_algorithm     = var.server_side_encryption.algorithm
    }
  }
}

resource "aws_s3_bucket_ownership_controls" "s3_bucket_ownership_controls" {
  bucket = aws_s3_bucket.s3_bucket.id

  rule {
    object_ownership = var.object_ownership
  }
}
