# -------------------------------------------------------------------------------------
#
# Copyright (c) 2025, WSO2 LLC. (http://www.wso2.com). All Rights Reserved.
#
# This software is the property of WSO2 LLC. and its suppliers, if any.
# Dissemination of any information or reproduction of any material contained
# herein in any form is strictly forbidden, unless permitted by WSO2 expressly.
# You may not alter or remove any copyright or other notice from copies of this content.
#
# --------------------------------------------------------------------------------------

locals {
  name_suffix = join("-", compact([var.environment, var.region]))
  global_budget_name = coalesce(
    var.global_budget_name_override,
    local.name_suffix != "" ? "${var.name_prefix}-${local.name_suffix}-global-budget" : "${var.name_prefix}-global-budget"
  )
  per_service_name_prefix = local.name_suffix != "" ? "${var.name_prefix}-${local.name_suffix}" : var.name_prefix
}
