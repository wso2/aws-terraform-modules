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
resource "time_rotating" "time_rotating" {
  rotation_days = var.rotation_days
}

# which then updates the leapfrog toggle
resource "toggles_leapfrog" "toggle" {
  trigger = time_rotating.time_rotating.rotation_rfc3339
}

resource "aws_iam_access_key" "iam_access_key" {
  user = var.iam_user_name

  lifecycle {
    replace_triggered_by = [
      toggles_leapfrog.toggle.alpha,
    ]

    # And we always want some credentials to exist, so create before destroy
    create_before_destroy = true
  }
}
