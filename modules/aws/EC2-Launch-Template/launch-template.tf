resource "aws_launch_template" "launch_template" {
  name                                 = local.name
  description                          = var.description
  image_id                             = var.image_id
  key_name                             = var.ssh_key_name
  instance_initiated_shutdown_behavior = var.instance_initiated_shutdown_behavior
  instance_type                        = var.instance_type
  vpc_security_group_ids               = var.vpc_security_group_ids
  user_data                            = var.user_data

  iam_instance_profile {
    arn = var.instanceProfile_arn
  }
  dynamic "tag_specifications" {
    for_each = ["instance", "volume", "network-interface"]
    content {
      resource_type = tag_specifications.value
      tags          = var.tags
    }
  }
  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size = var.disk_size
      encrypted   = var.enable_encryption_at_rest
      kms_key_id  = var.enable_encryption_at_rest == true ? var.kms_key_id : null
    }
  }
  metadata_options {
    http_tokens = var.imds_enabled
  }

  lifecycle {
    create_before_destroy = true
  }
}
