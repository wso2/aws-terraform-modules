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
  description = "Name of the application the infrastructure configuration belongs to"
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
  description = "Optional short name that tells several infrastructure configurations of the same application apart"
  type        = string
  default     = null
}

variable "description" {
  description = "Description of the infrastructure configuration"
  type        = string
  default     = null
}

variable "instance_profile_name" {
  description = "Name of the IAM instance profile of the build and test instances"
  type        = string
}

variable "instance_types" {
  description = "Instance types for the build and test instances, in order of preference"
  type        = list(string)

  validation {
    condition     = length(var.instance_types) > 0
    error_message = "instance_types must contain at least one instance type."
  }
}

variable "subnet_id" {
  description = "Subnet for the build and test instances. Null uses the default VPC."
  type        = string
  default     = null
}

variable "security_group_ids" {
  description = "Security groups for the build and test instances. Required when subnet_id is set."
  type        = list(string)
  default     = null
}

variable "key_pair" {
  description = "EC2 key pair for SSH access to the build instances. Null means no key pair."
  type        = string
  default     = null
}

variable "sns_topic_arn" {
  description = "SNS topic notified about build results"
  type        = string
  default     = null
}

variable "terminate_instance_on_failure" {
  description = "Terminate a build instance when its build fails. False keeps it for troubleshooting."
  type        = bool
  default     = true
}

variable "instance_metadata_options" {
  description = "Instance metadata service settings of the build and test instances. http_tokens = required enforces IMDSv2."
  type = object({
    http_tokens                 = optional(string, "required")
    http_put_response_hop_limit = optional(number, 1)
  })
  default = {}

  validation {
    condition     = contains(["required", "optional"], var.instance_metadata_options.http_tokens)
    error_message = "instance_metadata_options.http_tokens must be required or optional."
  }
}

variable "s3_logs" {
  description = "S3 location for the build logs. Null keeps logs in CloudWatch Logs only."
  type = object({
    bucket_name = string
    key_prefix  = optional(string)
  })
  default = null
}

variable "resource_tags" {
  description = "Tags applied to the build and test instances Image Builder launches"
  type        = map(string)
  default     = {}
}

variable "tags" {
  description = "Tags to be associated with the infrastructure configuration"
  type        = map(string)
  default     = {}
}
