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

# Ignore: AVD-AWS-0030 (https://avd.aquasec.com/misconfig/aws/ecr/avd-aws-0030/)
# Reason: Scanning on Image push should not be enabled by default and should be customizable per user requirement
# Ignore: AVD-AWS-0033 (https://avd.aquasec.com/misconfig/aws/ecr/avd-aws-0033/)
# Reason: While it has been enabled by default at the module level (check `encryption_type`)
# Further use of customer managed keys will be required per user requirement
# trivy:ignore:AVD-AWS-0030
# trivy:ignore:AVD-AWS-0033
resource "aws_ecr_repository" "ecr_repository" {
  name = var.generate_name == true ? join("-", [local.name_prefix, "ecr"]) : var.image_repo_name
  tags = var.tags

  image_tag_mutability = var.image_tag_mutability

  image_scanning_configuration {
    scan_on_push = var.scan_on_push # Custom parameter for AVD-AWS-0030
  }

  encryption_configuration {
    encryption_type = var.encryption_type # Custom parameter for AVD-AWS-0033
    kms_key         = var.encryption_type == "KMS" ? var.kms_key : null
  }
}