# -------------------------------------------------------------------------------------
#
# Copyright (c) 2026, WSO2 LLC. (https://www.wso2.com) All Rights Reserved.
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

variable "bucket" {
  description = "Name of the S3 bucket to put the object in"
  type        = string
}

variable "key" {
  description = "Key (path) of the object in the bucket"
  type        = string
}

variable "source_file" {
  description = "Path to a local file to upload. Set this or content, not both."
  type        = string
  default     = null
}

variable "content" {
  description = "Literal string content of the object. Set this or source_file, not both."
  type        = string
  default     = null
}

variable "content_type" {
  description = "MIME type of the object, e.g. text/yaml"
  type        = string
  default     = null
}

variable "server_side_encryption" {
  description = "Server-side encryption of the object: AES256, aws:kms or aws:kms:dsse. Null uses the bucket default."
  type        = string
  default     = null

  validation {
    condition     = var.server_side_encryption == null || contains(["AES256", "aws:kms", "aws:kms:dsse"], coalesce(var.server_side_encryption, "none"))
    error_message = "server_side_encryption must be AES256, aws:kms or aws:kms:dsse."
  }
}

variable "kms_key_id" {
  description = "ARN of the KMS key used when server_side_encryption is aws:kms or aws:kms:dsse"
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags to be associated with the object"
  type        = map(string)
  default     = {}
}
