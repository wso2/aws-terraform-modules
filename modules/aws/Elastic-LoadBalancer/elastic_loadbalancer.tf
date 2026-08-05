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

locals {
  # internal_usage_flag is typed string and callers may pass a bool ("true") or string.
  # Comparing a coerced string ("true") against a bool literal (== true) silently returns
  # false, so an internal NLB still hit the else-branch and created orphan (unassociated)
  # EIPs. tobool() normalizes both forms so the branches below are correct.
  is_internal = tobool(var.internal_usage_flag)
  is_shielded = tobool(var.enable_shield_protection)
}

# Ignore: AVD-AWS-0053 (https://avd.aquasec.com/misconfig/aws/elb/avd-aws-0053/)
# Reason: We may need public load balancers. As such this has been configured as a parameter.
# trivy:ignore:AVD-AWS-0053
resource "aws_lb" "lb" {
  name               = join("-", [var.project, var.application, var.environment, var.region, "elb"])
  internal           = local.is_internal # Defines the Load balancer network connectivity required by AVD-AWS-0053
  load_balancer_type = var.load_balancer_type
  security_groups    = var.security_group_ids

  enable_deletion_protection = var.deletion_protection_flag

  tags = var.tags

  enable_cross_zone_load_balancing = var.enable_cross_zone_load_balancing

  dynamic "subnet_mapping" {
    for_each = var.subnet_ids
    content {
      subnet_id            = subnet_mapping.value
      allocation_id        = var.internal_usage_flag == false ? aws_eip.eip[subnet_mapping.key].id : null
      private_ipv4_address = var.internal_usage_flag ? lookup(var.private_ip_addresses, subnet_mapping.key, null) : null
    }
  }
}

resource "aws_eip" "eip" {
  for_each = local.is_internal ? {} : var.subnet_ids
  domain   = "vpc"

  tags = var.tags
}

resource "aws_shield_protection" "shield_protection" {
  for_each     = !local.is_internal && local.is_shielded ? var.subnet_ids : {}
  name         = join("-", [var.project, var.application, var.environment, var.region, each.key, "elb-eip-shield-protection"])
  resource_arn = replace(aws_eip.eip[each.key].arn, "elastic-ip", "eip-allocation")

  tags = var.tags
}
