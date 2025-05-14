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

variable "project_id" {
  type = string
}
variable "role_name" {
  type = string
}
variable "db_user" {
  type = string
}
variable "db_password" {
  type = string
}
variable "database_name" {
  type = string
}
variable "scopes" {
  type = object({
    scope_assigned = bool
    name           = string
    type           = string
  })
  default = {
    scope_assigned = false
    name           = null
    type           = null
  }
}
