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
  natg_name = join("-", [var.project, var.application, var.environment, var.region, "natg"])
  natg_tags = merge(var.default_tags, { Name : local.natg_name })

  subnet_name = var.availability_zone == null ? join("-", [var.project, var.application, var.environment, var.region, "natg-snet"]) : join("-", [var.project, var.application, var.environment, var.availability_zone, "natg-snet"])
  subnet_tags = merge(var.default_tags, { Name : local.subnet_name })

  eip_name = join("-", [var.project, var.application, var.environment, var.region, "eip-natg"])
  eip_tags = merge(var.default_tags, { Name : local.eip_name })

  rt_name = var.availability_zone == null ? join("-", [var.project, var.application, var.environment, var.region, "natg-snet-rt"]) : join("-", [var.project, var.application, var.environment, var.availability_zone, "natg-snet-rt"])
  rt_tags = merge(var.default_tags, { Name : local.rt_name })
}
