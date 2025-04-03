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

# Ignore: AVD-AWS-0099 (https://avd.aquasec.com/misconfig/aws/ec2/avd-aws-0099)
# Reason: Description is a required variable for the security group
# trivy:ignore:AVD-AWS-0099
resource "aws_security_group" "security_group" {
  name        = join("-", [var.project, var.application, var.environment, var.region, "sg"])
  description = var.description
  vpc_id      = var.vpc_id

  tags = local.sg_tags
}