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

variable "application" {
  description = "Name of the application"
  type        = string
}

variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "region" {
  description = "AWS region"
  type        = string
}

variable "force_destroy" {
  description = "Whether to allow force destroy of the bucket"
  type        = bool
  default     = false
}

variable "block_public_acls" {
  description = "Whether Amazon S3 should block public ACLs for this bucket"
  type        = bool
  default     = true
}

variable "block_public_policy" {
  description = "Whether Amazon S3 should block public bucket policies for this bucket"
  type        = bool
  default     = true
}

variable "ignore_public_acls" {
  description = "Whether Amazon S3 should ignore public ACLs for this bucket"
  type        = bool
  default     = true
}

variable "restrict_public_buckets" {
  description = "Whether Amazon S3 should restrict public bucket policies for this bucket"
  type        = bool
  default     = true
}

variable "pipeline_stages" {
  description = "List of pipeline stages"
  type = list(object({
    name                        = string
    category                    = string
    provider                    = string
    input_artifacts             = list(string)
    output_artifacts            = list(string)
    buildspec                   = optional(string)
    custom_codebuild_role_arn   = optional(string)
    build_compute_type          = optional(string)
    build_image                 = optional(string)
    build_environment_type      = optional(string)
    build_privileged_mode       = optional(bool)
    build_environment_variables = optional(list(map(string)))
    build_vpc_config = optional(object({
      vpc_id             = string
      subnets            = list(string)
      security_group_ids = list(string)
    }))
  }))
}

variable "custom_codebuild_role_arn" {
  description = "Custom IAM role ARN for CodeBuild Build service role"
  type        = string
  default     = null
}

variable "eks_access" {
  description = "Boolean to determine whether the EKS cluster is accessible"
  type        = bool
  default     = false
}

variable "source_provider" {
  description = "Source provider for CodePipeline"
  type        = string
  default     = "CodeStarSourceConnection"
}

variable "source_connection_arn" {
  description = "ARN for the CodeStar source connection"
  type        = string
}

variable "source_repo" {
  description = "Full repository ID (e.g., username/repo-name)"
  type        = string
}

variable "source_branch" {
  description = "Branch to build from"
  type        = string
}
