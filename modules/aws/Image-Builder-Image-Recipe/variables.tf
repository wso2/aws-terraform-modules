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
  description = "Name of the application the recipe belongs to"
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
  description = "Optional short name that tells several recipes of the same application apart"
  type        = string
  default     = null
}

variable "recipe_version" {
  description = "Semantic version of the recipe (x.y.z). Versions are immutable: any change to the recipe needs a new version."
  type        = string

  validation {
    condition     = can(regex("^[0-9]+\\.[0-9]+\\.[0-9]+$", var.recipe_version))
    error_message = "recipe_version must be in the form x.y.z."
  }
}

variable "parent_image" {
  description = "Base image of the recipe: an AMI ID (ami-...) or an Image Builder image ARN"
  type        = string
}

variable "description" {
  description = "Description of the recipe"
  type        = string
  default     = null
}

variable "components" {
  description = "Components to run, in order. component_arn may be a version ARN or a <name>/x.x.x latest-version ARN; parameters maps parameter names to values."
  type = list(object({
    component_arn = string
    parameters    = optional(map(string), {})
  }))

  validation {
    condition     = length(var.components) > 0
    error_message = "components must contain at least one component."
  }
}

variable "block_device_mappings" {
  description = "Block device mappings of the build and test instances, and of the resulting image"
  type = list(object({
    device_name  = string
    no_device    = optional(bool)
    virtual_name = optional(string)
    ebs = optional(object({
      volume_size           = optional(number)
      volume_type           = optional(string)
      iops                  = optional(number)
      throughput            = optional(number)
      encrypted             = optional(bool)
      kms_key_id            = optional(string)
      snapshot_id           = optional(string)
      delete_on_termination = optional(bool, true)
    }))
  }))
  default = []
}

variable "working_directory" {
  description = "Working directory used during build and test workflows. Null uses the Image Builder default (/tmp)."
  type        = string
  default     = null
}

variable "user_data_base64" {
  description = "Base64-encoded user data run when the build instance launches"
  type        = string
  default     = null
}

variable "uninstall_ssm_agent_after_build" {
  description = "Whether to remove the Systems Manager agent from the image after the build. Set false to keep it, e.g. when instances are reached through Session Manager. Null keeps the Image Builder default."
  type        = bool
  default     = null
}

variable "tags" {
  description = "Tags to be associated with the recipe"
  type        = map(string)
  default     = {}
}
