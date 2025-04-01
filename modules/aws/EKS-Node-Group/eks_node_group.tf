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

resource "aws_eks_node_group" "eks_node_group" {
  cluster_name    = var.eks_cluster_name
  node_group_name = join("-", [var.eks_cluster_name, var.node_group_name, "node-group"])
  node_role_arn   = var.node_role_arn
  subnet_ids      = var.subnet_ids
  version         = var.k8s_version
  labels          = var.labels
  instance_types  = var.instance_types

  ami_type = var.ami_type

  lifecycle {
    ignore_changes = [
      launch_template, scaling_config
    ]
  }

  launch_template {
    id      = var.launch_template_id
    version = var.launch_template_version
  }

  dynamic "taint" {
    for_each = var.taints
    content {
      key    = taint.key
      value  = taint.value.value
      effect = taint.value.effect
    }
  }
  scaling_config {
    desired_size = var.desired_size
    max_size     = var.max_size
    min_size     = var.min_size
  }

  update_config {
    max_unavailable = var.max_unavailable
  }

  tags = local.ng_tags
}