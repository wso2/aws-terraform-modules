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
  node_role_arn   = var.node_iam_role_arn == null ? aws_iam_role.iam_role[0].arn : var.node_iam_role_arn
  subnet_ids      = var.subnet_ids
  version         = var.k8s_version
  labels          = var.labels
  instance_types  = var.instance_types

  capacity_type = var.capacity_type

  ami_type = var.ami_type

  lifecycle {
    ignore_changes = [
      launch_template, scaling_config[0].desired_size
    ]
  }

  launch_template {
    name    = aws_launch_template.eks_launch_template.name
    version = "$Latest"
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

  # Emitted only when enabled so callers on AWS provider versions older than
  # v5.84 (which introduced node_repair_config) are unaffected.
  dynamic "node_repair_config" {
    for_each = var.enable_node_auto_repair ? [1] : []
    content {
      enabled = true
    }
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  depends_on = [
    aws_iam_role_policy_attachment.amazon_eks_worker_node_policy,
    aws_iam_role_policy_attachment.amazon_eks_cni_policy,
    aws_iam_role_policy_attachment.amazon_ec2_container_registry_read_only,
  ]

  tags = local.ng_tags

}

resource "aws_launch_template" "eks_launch_template" {
  name_prefix = join("-", [var.eks_cluster_name, var.node_group_name, "launch-template"])

  image_id  = var.ami_type == "CUSTOM" ? var.custom_ami_id : null
  user_data = var.user_data

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size = var.node_disk_size
      volume_type = var.node_volume_type
      iops        = var.node_volume_iops
      throughput  = var.node_volume_throughput
      encrypted   = var.enable_encryption_at_rest
      kms_key_id  = var.enable_encryption_at_rest == true ? var.kms_key_id : null
    }
  }

  dynamic "credit_specification" {
    for_each = var.cpu_credits == null ? [] : [1]
    content {
      cpu_credits = var.cpu_credits
    }
  }

  tag_specifications {
    resource_type = "instance"
    tags          = local.ng_instance_tags
  }

  tag_specifications {
    resource_type = "volume"
    tags          = local.ng_volume_tags
  }

  metadata_options {
    http_tokens = var.imds_enabled
  }

  lifecycle {
    create_before_destroy = true
  }
}
