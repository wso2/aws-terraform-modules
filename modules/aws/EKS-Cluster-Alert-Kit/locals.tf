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
  eks_container_insights_metrics_namespace = "ContainerInsights"
  eks_alerts = merge(var.eks_alerts, {
    "max_node_count_warning" = {
      threshold           = var.max_node_count - 1
      evaluation_periods  = 1
      period              = 60
      statistic           = "Average"
      comparison_operator = "GreaterThanOrEqualToThreshold"
      metric_name         = "cluster_node_count"
      priority            = "Warning"
      enabled             = var.max_node_count != null ? true : false
    }
    "max_node_count_critical" = {
      threshold           = var.max_node_count
      evaluation_periods  = 1
      period              = 60
      statistic           = "Average"
      comparison_operator = "GreaterThanOrEqualToThreshold"
      metric_name         = "cluster_node_count"
      priority            = "Critical"
      enabled             = var.max_node_count != null ? true : false
    }
  })
}
