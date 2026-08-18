# -------------------------------------------------------------------------------------
#
# Copyright (c) 2026, WSO2 LLC. (http://www.wso2.com). All Rights Reserved.
#
# This software is the property of WSO2 LLC. and its suppliers, if any.
# Dissemination of any information or reproduction of any material contained
# herein in any form is strictly forbidden, unless permitted by WSO2 expressly.
# You may not alter or remove any copyright or other notice from copies of this content.
#
# --------------------------------------------------------------------------------------

# CloudWatch Observability Access Manager (OAM) link connecting this (source)
# account to a sink in a central monitoring account. The sink and a sink
# policy authorizing this account must already exist in the monitoring
# account, in the same region as the shared telemetry.
resource "aws_oam_link" "link" {
  label_template  = var.label_template
  resource_types  = var.resource_types
  sink_identifier = var.sink_identifier
  tags            = var.tags

  # Optional filters narrowing which log groups / metrics are shared. When
  # neither filter is set, everything covered by resource_types is shared.
  dynamic "link_configuration" {
    for_each = var.log_group_filter != null || var.metric_filter != null ? [1] : []
    content {
      dynamic "log_group_configuration" {
        for_each = var.log_group_filter != null ? [1] : []
        content {
          filter = var.log_group_filter
        }
      }
      dynamic "metric_configuration" {
        for_each = var.metric_filter != null ? [1] : []
        content {
          filter = var.metric_filter
        }
      }
    }
  }
}
