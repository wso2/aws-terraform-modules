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

output "efs_id" {
  value = aws_efs_file_system.efs_file_system.id
}
output "efs_arn" {
  value = aws_efs_file_system.efs_file_system.arn
}
output "efs_dns_name" {
  value = aws_efs_file_system.efs_file_system.dns_name
}
output "efs_access_point_ids" {
  value = zipmap(values(aws_efs_access_point.efs_access_point)[*].tags["Name"], values(aws_efs_access_point.efs_access_point)[*].id)
}
output "efs_access_point_arns" {
  value = zipmap(values(aws_efs_access_point.efs_access_point)[*].tags["Name"], values(aws_efs_access_point.efs_access_point)[*].arn)
}
