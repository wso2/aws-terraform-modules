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

variable "thumbprint_list" {
  description = "List of thumbprints of the OIDC provider"
  type        = list(string)
  default = []
}
variable "tags" {
  description = "Tags to be added with all resources"
  type        = map(string)
}
variable "url" {
  description = "URL of the OIDC provider"
  type        = string
}
