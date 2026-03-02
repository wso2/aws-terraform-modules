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

variable "name" {
  description = "The name of the parameter."
  type        = string
}

variable "type" {
  description = "The type of the parameter. Valid values are String, StringList, and SecureString."
  type        = string
  validation {
    condition     = contains(["String", "StringList", "SecureString"], var.type)
    error_message = "type must be one of: String, StringList, SecureString."
  }
}

variable "value" {
  description = "The value of the parameter."
  type        = string
  sensitive   = true
}

variable "tags" {
  description = "A map of tags to assign to the parameter."
  type        = map(string)
  default     = {}
}
