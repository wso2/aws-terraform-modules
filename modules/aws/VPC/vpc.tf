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

# avd-aws-0178 checks for whether flow logs are enabled.
# However whether flow logs are required  via a separate module at the subnet level (Refer VPC-Flow-Log Module)
# # https://avd.aquasec.com/misconfig/aws/iam/avd-aws-0178
# trivy:ignore:AVD-AWS-0178
resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_support   = var.enable_dns_support
  enable_dns_hostnames = var.enable_dns_hostnames

  tags = local.vpc_tags
}
