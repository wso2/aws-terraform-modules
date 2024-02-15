# -------------------------------------------------------------------------------------
#
# Copyright (c) 2024, WSO2 LLC. (http://www.wso2.com). All Rights Reserved.
#
# This software is the property of WSO2 LLC. and its suppliers, if any.
# Dissemination of any information or reproduction of any material contained
# herein in any form is strictly forbidden, unless permitted by WSO2 expressly.
# You may not alter or remove any copyright or other notice from copies of this content.
#
# --------------------------------------------------------------------------------------

output "backup_vault_arn" {
  value      = aws_backup_vault.backup_vault.arn
  depends_on = [aws_backup_vault.backup_vault]
}
output "backup_vault_name" {
  value      = aws_backup_vault.backup_vault.name
  depends_on = [aws_backup_vault.backup_vault]
}
