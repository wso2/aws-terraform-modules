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

# Writes a new version to an existing secret that is created outside this module
resource "aws_secretsmanager_secret_version" "secretsmanager_secret_version" {
  secret_id     = var.secret_id
  secret_string = var.secret_string
}
