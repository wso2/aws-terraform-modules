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
variable "tags" {
  type        = map(string)
  description = "Tags to be associated with the EKS"
  default     = {}
}
variable "encryption_type" {
  type        = string
  description = "Encryption type for the ECR"
  default     = "AES256"
}
variable "kms_key" {
  type        = string
  description = "KMS key ID for the ECR"
  default     = null
}
variable "scan_on_push" {
  type        = bool
  description = "Whether to scan on push"
  default     = false
}
variable "image_tag_mutability" {
  type        = string
  description = "Whether to allow image tag mutability"
  default     = "IMMUTABLE"
}
variable "image_repo_name" {
  type        = string
  description = "Name of the image repository"
  default     = null
}
variable "generate_name" {
  type        = bool
  description = "Whether to generate name for the image repository"
  default     = false
}
variable "external_admin_account_ids" {
  type        = list(string)
  description = "List of external admin account IDs"
  default     = []
}
variable "external_pull_only_account_ids" {
  type        = list(string)
  description = "List of external pull only account IDs"
  default     = []
}
