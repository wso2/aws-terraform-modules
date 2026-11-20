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

# The destination file system must have replication overwrite protection disabled
resource "aws_efs_replication_configuration" "efs_replication" {
  source_file_system_id = var.source_file_system_id

  destination {
    region                 = var.destination_region
    file_system_id         = var.destination_file_system_id
    availability_zone_name = var.destination_availability_zone_name
    kms_key_id             = var.destination_kms_key_id
  }
}
