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
  flow_log_name   = join("-", [var.vpc_flow_log_abbreviation, var.vpc_flow_log_name])
  flow_log_tags   = merge(var.tags, { Name : local.flow_log_name })
  iam_role_name   = join("-", [var.iam_role_abbreviation, var.vpc_flow_log_name])
  iam_policy_name = join("-", [var.iam_policy_abbreviation, var.vpc_flow_log_name])
}
