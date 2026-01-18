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

variable "s3_bucket_name" {
  type        = string
  description = "The name for the S3 Bucket"
}

variable "s3_bucket_abbreviation" {
  type        = string
  description = "The abbreviation for the S3 Bucket resource name"
  default     = "s3"
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
