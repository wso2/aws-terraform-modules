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

resource "aws_ami" "custom_ami" {
  name                = var.custom_ami_name
  description         = var.custom_ami_description
  architecture        = var.custom_ami_architecture
  virtualization_type = var.custom_ami_virtualization_type
  imds_support        = var.custom_ami_imds_support
  tags                = var.custom_ami_tags
}
