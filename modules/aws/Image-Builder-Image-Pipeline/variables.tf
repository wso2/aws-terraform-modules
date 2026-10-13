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
  description = "Name of the application the image pipeline belongs to"
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
  description = "Optional short name that tells several image pipelines of the same application apart"
  type        = string
  default     = null
}

variable "description" {
  description = "Description of the image pipeline"
  type        = string
  default     = null
}

variable "image_recipe_arn" {
  description = "ARN of the image recipe the pipeline builds"
  type        = string
}

variable "infrastructure_configuration_arn" {
  description = "ARN of the infrastructure configuration for the build and test instances"
  type        = string
}

variable "distribution_configuration_arn" {
  description = "ARN of the distribution configuration. Null keeps the AMI in this region and account only."
  type        = string
  default     = null
}

variable "enhanced_image_metadata_enabled" {
  description = "Collect the installed packages of the image as additional metadata"
  type        = bool
  default     = true
}

variable "status" {
  description = "Status of the pipeline: ENABLED or DISABLED"
  type        = string
  default     = "ENABLED"

  validation {
    condition     = contains(["ENABLED", "DISABLED"], var.status)
    error_message = "status must be ENABLED or DISABLED."
  }
}

variable "image_tests_enabled" {
  description = "Run the test phase of the recipe's components on an instance launched from the new image"
  type        = bool
  default     = true
}

variable "image_tests_timeout_minutes" {
  description = "Time limit of the test phase, in minutes (60 to 1440)"
  type        = number
  default     = 720

  validation {
    condition     = var.image_tests_timeout_minutes >= 60 && var.image_tests_timeout_minutes <= 1440
    error_message = "image_tests_timeout_minutes must be between 60 and 1440."
  }
}

variable "image_scanning_enabled" {
  description = "Scan the new image with Amazon Inspector. Requires Inspector enabled for the account."
  type        = bool
  default     = false
}

variable "schedule" {
  description = "Schedule that starts the pipeline automatically. Null means the pipeline runs only when started manually or by automation."
  type = object({
    schedule_expression                = string
    pipeline_execution_start_condition = optional(string, "EXPRESSION_MATCH_AND_DEPENDENCY_UPDATES_AVAILABLE")
    timezone                           = optional(string)
  })
  default = null
}

variable "tags" {
  description = "Tags to be associated with the image pipeline"
  type        = map(string)
  default     = {}
}
