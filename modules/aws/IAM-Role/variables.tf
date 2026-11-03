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

variable "project" {
  type        = string
  description = "Name of the project"
}
variable "environment" {
  type        = string
  description = "Name of the environment"
}
variable "region" {
  type        = string
  description = "Code of the region"
}
variable "application" {
  type        = string
  description = "Purpose of the ECR"
}
variable "assume_role_policy" {
  type = string
}
variable "tags" {
  type        = map(string)
  description = "Tags to be associated with the EKS"
  default     = {}
}
variable "permissions_boundary" {
  type        = string
  description = "ARN of the managed policy to set as the permissions boundary of the IAM Role; null for none"
  default     = null
}
variable "name_override" {
  description = "Role name to use instead of the generated name"
  type        = string
  default     = null
}
variable "description" {
  description = "Description of the IAM Role"
  type        = string
  default     = null
}
variable "inline_policies" {
  description = "Inline policies to embed in the IAM Role keyed by a stable label with the policy name and JSON document"
  type = map(object({
    name   = string
    policy = string
  }))
  default = {}
}
