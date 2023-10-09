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
  name_prefix = var.availability_zone == null ? join("-", [var.project, var.application, var.environment, var.region]) : join("-", [var.project, var.application, var.environment, var.availability_zone])
  ec2_name    = join("-", [local.name_prefix, "ec2"])
  rt_name     = join("-", [local.name_prefix, "ec2-snet-rt"])
  subnet_name = join("-", [local.name_prefix, "ec2-snet"])
  nic_name    = join("-", [local.name_prefix, "ec2-nic"])
  ip_name     = join("-", [local.name_prefix, "ec2-eip"])
  volume_name = join("-", [local.name_prefix, "ec2-volume"])
  ec2_tags    = merge(var.tags, { Name : local.ec2_name })
  rt_tags     = merge(var.tags, { Name : local.rt_name })
  subnet_tags = merge(var.tags, { Name : local.subnet_name })
  nic_tags    = merge(var.tags, { Name : local.nic_name })
  ip_tags     = merge(var.tags, { Name : local.ip_name })
  volume_tags = merge(var.tags, { Name : local.volume_name })
}
