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

variable "project" {
  description = "Name of the project"
  type        = string
}

variable "application" {
  description = "Name of the application the component belongs to"
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

variable "name" {
  description = "Optional short name that tells several components of the same application apart, e.g. build or verify"
  type        = string
  default     = null
}

variable "component_version" {
  description = "Semantic version of the component (x.y.z). Versions are immutable: changing the document needs a new version."
  type        = string

  validation {
    condition     = can(regex("^[0-9]+\\.[0-9]+\\.[0-9]+$", var.component_version))
    error_message = "component_version must be in the form x.y.z."
  }
}

variable "platform" {
  description = "Platform of the component: Linux, Windows or macOS"
  type        = string
  default     = "Linux"

  validation {
    condition     = contains(["Linux", "Windows", "macOS"], var.platform)
    error_message = "platform must be Linux, Windows or macOS."
  }
}

variable "description" {
  description = "Description of the component"
  type        = string
  default     = null
}

variable "change_description" {
  description = "Description of what changed in this version of the component"
  type        = string
  default     = null
}

variable "uri" {
  description = "S3 URI of the component document, e.g. s3://<bucket>/<key>. Required for documents over 16,000 characters. Set this or data, not both."
  type        = string
  default     = null
}

variable "data" {
  description = "Inline YAML component document, up to 16,000 characters. Set this or uri, not both."
  type        = string
  default     = null
}

variable "kms_key_id" {
  description = "ARN of the KMS key used to encrypt the component"
  type        = string
  default     = null
}

variable "supported_os_versions" {
  description = "Operating system versions the component supports, e.g. [\"Ubuntu 24\"]. Null allows any version of the platform."
  type        = set(string)
  default     = null
}

variable "skip_destroy" {
  description = "Keep the old version in AWS when the component is destroyed or replaced by a new version"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags to be associated with the component"
  type        = map(string)
  default     = {}
}
