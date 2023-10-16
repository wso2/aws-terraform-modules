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

# avd-aws-0053 checks whether the Load Balancer is internal or not.
# However based on the use case we may need public load balancers which has been configured as a parameter.
# https://avd.aquasec.com/misconfig/aws/iam/avd-aws-0053/
# trivy:ignore:AVD-AWS-0053
resource "aws_lb" "lb" {
  name               = join("-", [var.project, var.application, var.environment, var.region, "elb"])
  internal           = var.internal_usage_flag # Defines the Load balancer network connectivity required by AVD-AWS-0053
  load_balancer_type = var.load_balancer_type
  security_groups    = var.security_group_ids
  subnets            = var.subnet_ids

  enable_deletion_protection = var.deletion_protection_flag

  tags = var.tags
}
