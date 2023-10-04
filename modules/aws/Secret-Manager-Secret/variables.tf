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

variable "secret_string" {
  type        = string
  description = "String value for string"
}
variable "secret_name" {
  type        = string
  description = "Secret name for string"
}
variable "tags" {
  type        = map(string)
  description = "Tags for string"
  default     = {}
}
variable "create_secret_reader_iam_policy" {
  type        = bool
  description = "Create IAM policy for secret reader"
  default     = true
}
variable "access_principals" {
  type        = list(string)
  description = "Access principals for secret"
  default     = []
}
variable "recovery_window_in_days" {
  type = number
  description = "Recovery window in days for secret"
  default = 7
}
