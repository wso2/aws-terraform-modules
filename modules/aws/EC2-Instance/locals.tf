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
  name_prefix            = var.availability_zone == null ? var.ec2_instance_abbreviation : join("-", [var.ec2_instance_abbreviation, var.availability_zone])
  ec2_name               = join("-", [local.name_prefix, var.ec2_instance_name])
  rt_name                = join("-", [local.name_prefix, var.ec2_rt_abbreviation, var.ec2_instance_name])
  subnet_name            = join("-", [local.name_prefix, var.ec2_subnet_abbreviation, var.ec2_instance_name])
  nic_name               = join("-", [local.name_prefix, var.ec2_nic_abbreviation, var.ec2_instance_name])
  ip_name                = join("-", [local.name_prefix, var.ec2_eip_abbreviation, var.ec2_instance_name])
  volume_name            = join("-", [local.name_prefix, var.ec2_volume_abbreviation, var.ec2_instance_name])
  shield_protection_name = join("-", [local.name_prefix, var.ec2_shield_protection_abbreviation, var.ec2_instance_name])
  key_pair_name          = join("-", [local.name_prefix, var.ec2_key_pair_abbreviation, var.ec2_instance_name])
  ec2_tags               = merge(var.tags, { Name : local.ec2_name })
  rt_tags                = merge(var.tags, { Name : local.rt_name })
  subnet_tags            = merge(var.tags, { Name : local.subnet_name })
  nic_tags               = merge(var.tags, { Name : local.nic_name })
  ip_tags                = merge(var.tags, { Name : local.ip_name })
  volume_tags            = merge(var.tags, { Name : local.volume_name })
}
