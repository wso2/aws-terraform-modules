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

resource "aws_kms_key" "kms_key" {
  description             = var.description
  key_usage               = var.key_usage
  deletion_window_in_days = var.deletion_window_in_days
  policy                  = var.policy
  is_enabled              = var.is_enabled
  multi_region            = var.is_multi_region
  enable_key_rotation     = var.enable_key_rotation

  tags = local.tags
}
