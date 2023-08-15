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

resource "aws_flow_log" "flow_log" {
  log_destination      = var.log_destination
  log_destination_type = var.log_destination_type
  traffic_type         = var.traffic_type

  vpc_id                        = var.vpc_id
  eni_id                        = var.eni_id
  transit_gateway_id            = var.transit_gateway_id
  subnet_id                     = var.subnet_id
  transit_gateway_attachment_id = var.transit_gateway_attachment_id
  log_format                    = var.log_format

  max_aggregation_interval = var.max_aggregation_interval
  iam_role_arn             = var.log_destination_type == "cloud-watch-logs" ? aws_iam_role.iam_role.0.arn : null
  tags                     = local.flow_log_tags
}
