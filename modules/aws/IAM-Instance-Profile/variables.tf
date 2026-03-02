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
  description = "The name of the instance profile."
  type        = string
}

variable "role" {
  description = "The name of the role to include in the instance profile."
  type        = string
}

variable "tags" {
  description = "A map of tags to assign to the instance profile."
  type        = map(string)
  default     = {}
}
