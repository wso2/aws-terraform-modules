# -------------------------------------------------------------------------------------
#
# Copyright (c) 2025, WSO2 LLC. (http://www.wso2.com). All Rights Reserved.
#
# This software is the property of WSO2 LLC. and its suppliers, if any.
# Dissemination of any information or reproduction of any material contained
# herein in any form is strictly forbidden, unless permitted by WSO2 expressly.
# You may not alter or remove any copyright or other notice from copies of this content.
#
# --------------------------------------------------------------------------------------

variable "shortened_region_name" {
  type = string
}
variable "shortened_application_name" {
  type = string
}
variable "shortened_environment_name" {
  type = string
}
variable "shortened_project_name" {
  type = string
}
variable "secrets" {
  type = list(object({
    name        = string
    value       = string
    description = optional(string)
  }))
}

variable "secret_access_bindings" {
  type = list(object({
    namespace      = string
    serviceAccount = string
    secrets        = list(string)
  }))
}
variable "aws_account_id" {
  type = string
}

variable "oidc_provider_url" {
  type = string
}
