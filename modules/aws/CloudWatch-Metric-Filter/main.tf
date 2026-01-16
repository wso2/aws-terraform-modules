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

resource "aws_cloudwatch_log_metric_filter" "filter" {
  name           = var.name
  log_group_name = var.log_group_name
  pattern        = var.pattern

  metric_transformation {
    name          = var.metric_name
    namespace     = var.metric_namespace
    value         = var.metric_value
    unit          = var.metric_unit
    default_value = var.metric_default_value
    dimensions    = var.metric_dimensions
  }
}
