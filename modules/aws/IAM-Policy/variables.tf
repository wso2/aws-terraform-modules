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

variable "iam_policy_name" {
  type        = string
  description = "The name for the IAM policy"
}

variable "iam_policy_abbreviation" {
  type        = string
  description = "The abbreviation for the IAM policy resource name"
  default     = "ip"
}

variable "tags" {
  type        = map(string)
  description = "Tags to be associated with the EKS"
  default     = {}
}
variable "policy" {
  type = string
}
