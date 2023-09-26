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

resource "aws_efs_file_system" "efs_file_system" {
  availability_zone_name = var.availability_zone_name
  kms_key_id             = var.encrypted == true ? var.kms_key_id : null
  encrypted              = var.encrypted

  performance_mode                = var.performance_mode
  throughput_mode                 = var.throughput_mode
  provisioned_throughput_in_mibps = var.throughput_mode == "provisioned" ? var.provisioned_throughput_in_mibps : null

  creation_token = var.creation_token

  tags = local.tags
}

resource "aws_efs_access_point" "efs_access_point" {
  for_each       = var.efs_access_points
  file_system_id = aws_efs_file_system.efs_file_system.id

  dynamic "posix_user" {
    for_each = each.value.posix_user == null ? [] : [each.value.posix_user]
    content {
      gid = each.value.posix_user.gid
      uid = each.value.posix_user.uid
    }
  }

  dynamic "root_directory" {
    for_each = each.value.root_directory == null ? [] : [each.value.root_directory]
    content {
      dynamic "creation_info" {
        for_each = each.value.root_directory.creation_info == null ? [] : [each.value.root_directory.creation_info]
        content {
          owner_gid   = each.value.root_directory.creation_info.owner_gid
          owner_uid   = each.value.root_directory.creation_info.owner_uid
          permissions = each.value.root_directory.creation_info.permissions
        }
      }
      path = each.value.root_directory.path
    }
  }
}

resource "aws_efs_mount_target" "efs_mount_target" {
  for_each        = var.efs_mount_targets
  file_system_id  = aws_efs_file_system.efs_file_system.id
  subnet_id       = each.value.subnet_id
  security_groups = each.value.security_groups
  ip_address      = each.value.ip_address
}
