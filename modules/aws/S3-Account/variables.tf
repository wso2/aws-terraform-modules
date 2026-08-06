# -------------------------------------------------------------------------------------
#
# Copyright (c) 2025, WSO2 LLC. (https://www.wso2.com) All Rights Reserved.
#
# WSO2 LLC. licenses this file to you under the Apache License,
# Version 2.0 (the "License"); you may not use this file except
# in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied. See the License for the
# specific language governing permissions and limitations
# under the License.
#
# --------------------------------------------------------------------------------------

variable "project" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Name of the environment"
  type        = string
}

variable "region" {
  description = "Code of the region"
  type        = string
}

variable "application" {
  description = "Purpose of the EKS Cluster"
  type        = string
}

variable "tags" {
  description = "Tags for the resources"
  type        = map(string)
  default     = {}
}

variable "block_public_acls" {
  description = "Block public access to the bucket"
  type        = bool
  default     = true
}

variable "block_public_policy" {
  description = "Block public bucket policies"
  type        = bool
  default     = true
}

variable "ignore_public_acls" {
  description = "Ignore existing public ACLs on the bucket"
  type        = bool
  default     = true
}

variable "restrict_public_buckets" {
  description = "Restrict public buckets"
  type        = bool
  default     = true
}

variable "server_side_encryption" {
  description = "Server side encryption to be applied to the bucket"
  type = object({
    algorithm  = string
    kms_key_id = optional(string, null)
  })
  default = {
    algorithm = "AES256"
  }
}

variable "versioning_enabled" {
  description = "Enable versioning for the bucket"
  type        = bool
  default     = true
}

variable "force_destroy" {
  description = "Force destroy the bucket"
  type        = bool
  default     = false
}

variable "object_ownership" {
  description = "Object ownership for the bucket"
  type        = string
  default     = "BucketOwnerPreferred"
}

variable "bucket_name" {
  description = "Explicit bucket name. Null falls back to the join(project, application, environment, region, \"bucket\") default."
  type        = string
  default     = null
}

variable "acl" {
  description = "Canned ACL to apply to the bucket, e.g. \"log-delivery-write\". Null skips setting an ACL."
  type        = string
  default     = null
}

variable "lifecycle_expiration_days" {
  description = "Days after which objects expire. Null skips creating a lifecycle rule."
  type        = number
  default     = null
}

variable "lifecycle_rule_id" {
  description = "ID of the expiration lifecycle rule, when lifecycle_expiration_days is set"
  type        = string
  default     = "expire-objects"
}
