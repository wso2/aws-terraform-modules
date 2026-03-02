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

resource "aws_key_pair" "key_pair" {
  key_name   = join("-", [local.name_prefix, "ec2-kp"])
  public_key = var.ssh_public_key
  tags       = var.tags
}

resource "aws_launch_template" "launch_template" {
  name_prefix            = join("-", [local.name_prefix, "ec2-lt"])
  image_id               = var.image_id
  instance_type          = var.instance_type
  key_name               = aws_key_pair.key_pair.key_name
  vpc_security_group_ids = var.security_group_ids

  iam_instance_profile {
    name = var.iam_instance_profile_name
  }

  dynamic "block_device_mappings" {
    for_each = var.block_device_mappings
    content {
      device_name = block_device_mappings.value.device_name
      ebs {
        delete_on_termination = block_device_mappings.value.ebs.delete_on_termination
        volume_size           = block_device_mappings.value.ebs.volume_size
        volume_type           = block_device_mappings.value.ebs.volume_type
        encrypted             = block_device_mappings.value.ebs.encrypted
      }
    }
  }

  dynamic "metadata_options" {
    for_each = var.metadata_options != null ? [var.metadata_options] : []
    content {
      http_endpoint               = metadata_options.value.http_endpoint
      http_tokens                 = metadata_options.value.http_tokens
      http_put_response_hop_limit = metadata_options.value.http_put_response_hop_limit
      instance_metadata_tags      = metadata_options.value.instance_metadata_tags
      http_protocol_ipv6          = metadata_options.value.http_protocol_ipv6
    }
  }

  user_data = var.user_data

  dynamic "tag_specifications" {
    for_each = var.tag_specifications
    content {
      resource_type = tag_specifications.value.resource_type

      tags = merge(
        var.tags,
        tag_specifications.value.tags
      )
    }
  }
}
