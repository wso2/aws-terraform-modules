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

resource "aws_efs_access_point" "access_point" {
  file_system_id = var.file_system_id
  posix_user {
    gid = var.posix_user_gid
    uid = var.posix_user_uid
  }
  root_directory {
    path = var.root_directory_path
    creation_info {
      owner_gid     = var.owner_gid
      owner_uid     = var.owner_uid
      permissions   = var.permissions
    }
  }
  tags = var.tags
}
