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

output "access_point_arn" {
  value = aws_efs_access_point.access_point.arn
}
output "access_point_file_system_arn" {
  value = aws_efs_access_point.access_point.file_system_arn
}
output "access_point_id" {
  value = aws_efs_access_point.access_point.id
}
