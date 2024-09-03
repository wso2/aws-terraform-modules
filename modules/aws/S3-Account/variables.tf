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
  description = "Purpose of the EKS Cluster"
}
variable "tags" {
  type        = map(string)
  description = "Tags for the resources"
  default     = {}
}
variable "acl" {
  type        = string
  description = "ACL to be applied to the bucket"
}
variable "block_public_acls" {
  type        = bool
  description = "Block public access to the bucket"
  default     = true
}
variable "restrict_public_buckets" {
  type        = bool
  description = "Restrict public buckets"
  default     = true
}
variable "server_side_encryption" {
  type = object({
    algorithm  = string
    kms_key_id = optional(string, null)
  })
  description = "Server side encryption to be applied to the bucket"
  default = {
    algorithm = "AES256"
  }
}
variable "versioning_enabled" {
  type        = bool
  description = "Enable versioning for the bucket"
  default     = true
}
