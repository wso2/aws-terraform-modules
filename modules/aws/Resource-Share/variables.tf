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

variable "tags" {
  type        = map(string)
  description = "Tags to be added with all resources"
}
variable "resource_arn" {
  type        = string
  description = "ARN of the resource to share"
}
variable "account_id" {
  type        = string
  description = "ID of the account to share the resource with"
}
