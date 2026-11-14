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

output "replication_id" {
  value = aws_efs_replication_configuration.efs_replication.id
}
output "destination_file_system_id" {
  value = aws_efs_replication_configuration.efs_replication.destination[0].file_system_id
}
output "destination_status" {
  value = aws_efs_replication_configuration.efs_replication.destination[0].status
}
