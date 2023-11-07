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

variable "type" {
  description = "Type of certificate"
  type        = string
  default     = "ROOT"
}
variable "common_name" {
  description = "The common name of the certificate"
  type        = string
}
variable "country" {
  description = "The country of the certificate"
  type        = string
}
variable "state" {
  description = "The state of the certificate"
  type        = string
}
variable "locality" {
  description = "The locality of the certificate"
  type        = string
}
variable "organization" {
  description = "The organization of the certificate"
  type        = string
}
variable "organizational_unit" {
  description = "The organizational unit of the certificate"
  type        = string
}
variable "signing_algorithm" {
  description = "The signing algorithm of the certificate"
  type        = string
  default     = "SHA256WITHRSA"
}
variable "key_algorithm" {
  description = "The key algorithm of the certificate"
  type        = string
  default     = "RSA_2048"
}
variable "validity_unit" {
  description = "The validity units of the certificate"
  type        = string
  default     = "YEARS"
}
variable "validity" {
  description = "The validity in validity units of the certificate"
  type        = number
  default     = 1
}
variable "permanent_deletion_time_in_days" {
  description = "Time to permenantly delete a CA"
  type        = number
  default     = 7
}
variable "tags" {
  description = "Tags to be used with the ACMPA"
  type        = map(string)
  default     = {}
}