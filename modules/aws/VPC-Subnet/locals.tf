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
  # Normalise: availability_zones (list) takes precedence over availability_zone (scalar).
  # Treat empty/null as a single "no-AZ" subnet using the base cidr_block as-is.
  _azs_resolved = length(var.availability_zones) > 0 ? var.availability_zones : (var.availability_zone != null ? [var.availability_zone] : [])
  azs           = length(local._azs_resolved) > 0 ? local._azs_resolved : [null]
  az_count      = length(local.azs)

  # Number of extra bits to evenly subdivide the base CIDR across all AZs (0 when single)
  newbits = local.az_count > 1 ? ceil(log(local.az_count, 2)) : 0

  # Build the per-subnet map keyed by AZ name (or "default" when no AZ given)
  subnet_map = {
    for idx, az in local.azs :
    (az != null ? az : "default") => {
      az          = az
      cidr_block  = length(var.cidr_blocks) > 0 ? var.cidr_blocks[idx] : (local.az_count > 1 ? cidrsubnet(var.cidr_block, local.newbits, idx) : var.cidr_block)
      name_prefix = az != null ? join("-", [var.project, var.application, var.environment, var.region, az]) : join("-", [var.project, var.application, var.environment, var.region])
    }
  }
}
