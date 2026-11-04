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

variable "repository_name" {
  type        = string
  description = "Name of the public ECR repository."
}

variable "description" {
  type        = string
  description = "Short description shown on the public gallery."
  default     = ""
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to the repository."
  default     = {}
}
