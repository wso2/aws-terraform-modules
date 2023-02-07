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

resource "aws_instance" "ec2_instance" {
  ami               = var.ec2_ami
  instance_type     = var.ec2_instance_type
  availability_zone = var.availability_zone

  tags = local.ec2_tags

  network_interface {
    device_index         = 0
    network_interface_id = aws_network_interface.ec2_network_interface.id
  }
}