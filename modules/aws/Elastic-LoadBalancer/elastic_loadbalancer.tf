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

# Ignore: AVD-AWS-0053 (https://avd.aquasec.com/misconfig/aws/elb/avd-aws-0053/)
# Reason: We may need public load balancers. As such this has been configured as a parameter.
# trivy:ignore:AVD-AWS-0053
resource "aws_lb" "lb" {
  name               = join("-", [var.elb_abbreviation, var.elb_name])
  internal           = var.internal_usage_flag # Defines the Load balancer network connectivity required by AVD-AWS-0053
  load_balancer_type = var.load_balancer_type
  security_groups    = var.security_group_ids

  enable_deletion_protection = var.deletion_protection_flag

  tags = var.tags

  dynamic "subnet_mapping" {
    for_each = var.subnet_ids
    content {
      subnet_id            = subnet_mapping.value
      allocation_id        = var.internal_usage_flag == false ? aws_eip.eip[subnet_mapping.key].id : null
      private_ipv4_address = var.internal_usage_flag == true ? var.private_ip_addresses[subnet_mapping.key] : null
    }
  }
}

resource "aws_eip" "eip" {
  for_each = var.internal_usage_flag == true ? {} : var.subnet_ids
  domain   = "vpc"

  tags = var.tags
}

resource "aws_shield_protection" "shield_protection" {
  for_each     = var.internal_usage_flag == true || !var.enable_shield_protection ? {} : var.subnet_ids
  name         = join("-", [var.shield_protection_abbreviation, each.key])
  resource_arn = aws_eip.eip[each.key].arn

  tags = var.tags
}
