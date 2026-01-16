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

variable "kms_key_name" {
  type        = string
  description = "The name for the KMS Key"
}

variable "kms_key_abbreviation" {
  type        = string
  description = "The abbreviation for the KMS Key resource name"
  default     = "cmk"
}

variable "tags" {
  type        = map(string)
  description = "The tags for the resources"
  default     = {}
}
variable "key_usage" {
  type        = string
  description = "The intended use of the key. Valid values: ENCRYPT_DECRYPT or SIGN_VERIFY"
  default     = "ENCRYPT_DECRYPT"
}
variable "deletion_window_in_days" {
  type        = number
  description = "Duration in days after which the key is deleted after destruction of the resource, must be between 7 and 30 days"
  default     = 30
}
variable "description" {
  type        = string
  description = "The description of the key as viewed in AWS console"
  default     = "KMS key for WSO2 API Manager"
}
variable "policy" {
  type        = string
  description = "The policy of the key as viewed in AWS console"
  default     = null
}
variable "is_enabled" {
  type        = bool
  description = "Specifies whether the key is enabled. Defaults to true."
  default     = true
}
variable "is_multi_region" {
  type        = bool
  description = "Specifies whether the key is multi-region. Defaults to false."
  default     = false
}
variable "enable_key_rotation" {
  type        = bool
  description = "Specifies whether key rotation is enabled. Defaults to false."
  default     = true
}
