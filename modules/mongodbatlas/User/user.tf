# -------------------------------------------------------------------------------------
#
# Copyright (c) 2025, WSO2 Inc. (http://www.wso2.com). All Rights Reserved.
#
# This software is the property of WSO2 Inc. and its suppliers, if any.
# Dissemination of any information or reproduction of any material contained
# herein in any form is strictly forbidden, unless permitted by WSO2 expressly.
# You may not alter or remove any copyright or other notice from copies of this content.
#
# --------------------------------------------------------------------------------------

resource "mongodbatlas_database_user" "user" {
  username           = var.db_user
  password           = var.db_password
  project_id         = var.project_id
  auth_database_name = "admin"

  roles {
    role_name     = var.role_name
    database_name = var.database_name
  }

  dynamic "scopes" {
    for_each = var.scopes["scope_assigned"] == true ? [1] : []
    content {
      name = var.scopes["name"]
      type = var.scopes["type"]
    }
  }
}
