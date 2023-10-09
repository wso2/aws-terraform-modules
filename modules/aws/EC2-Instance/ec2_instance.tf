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

resource "aws_key_pair" "key_pair" {
  count      = var.add_ssh_key == true ? 1 : 0
  key_name   = join("-", [local.name_prefix, "ec2-kp"])
  public_key = var.ssh_public_key

  tags = var.tags
}

resource "aws_instance" "ec2_instance" {
  ami               = var.ec2_ami
  instance_type     = var.ec2_instance_type
  availability_zone = var.availability_zone

  key_name = var.add_ssh_key == true ? aws_key_pair.key_pair.0.key_name : null

  tags = local.ec2_tags

  iam_instance_profile = aws_iam_instance_profile.iam_instance_profile.name

  network_interface {
    device_index         = 0
    network_interface_id = aws_network_interface.ec2_network_interface.id
  }

  root_block_device {
    encrypted   = var.encrypt_root_volume
    kms_key_id  = var.encrypt_root_volume == true ? var.kms_key_id : null
    volume_size = var.root_volume_size
    tags        = local.volume_tags
  }
}
