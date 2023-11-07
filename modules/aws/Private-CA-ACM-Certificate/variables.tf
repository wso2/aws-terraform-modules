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

variable "tags" {
  description = "Tags to be associated with the resource"
  type        = map(string)
  default     = {}
}
variable "domain_name" {
  description = "Domain name"
  type        = string
}
variable "subject_alternative_names" {
  description = "Subject alternative names"
  type        = list(string)
  default     = []
}
variable "certificate_authority_arn" {
  description = "Certificate authority arn"
  type        = string
}
