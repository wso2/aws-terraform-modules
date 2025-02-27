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

variable "custom_codebuild_role_arn" {
  description = "Custom IAM role ARN for CodeBuild Build service role"
  type        = string
  default     = null
}

variable "build_compute_type" {
  description = "Compute type for the build stage"
  type        = string
  default     = "BUILD_GENERAL1_SMALL"
}

variable "build_image" {
  description = "Docker image for the build stage"
  type        = string
  default     = "aws/codebuild/amazonlinux-x86_64-standard:5.0"
}

variable "build_environment_type" {
  description = "Build environment type"
  type        = string
  default     = "LINUX_CONTAINER"
}

variable "build_privileged_mode" {
  description = "Whether the build stage should run in privileged mode"
  type        = bool
  default     = false
}

variable "build_environment_variables" {
  description = "Environment variables for the build stage"
  type        = list(map(string))
  default     = []
}

variable "build_vpc_config" {
  description = "VPC configuration for the build stage"
  type = object({
    vpc_id             = string
    subnets            = list(string)
    security_group_ids = list(string)
  })
  default = null
}

variable "buildspec_file" {
  description = "Buildspec file for the build stage"
  type        = string
  default     = "buildspec.yml"
}

variable "custom_codedeploy_role_arn" {
  description = "Custom IAM role ARN for CodeBuild Deploy service role"
  type        = string
  default     = null
}

variable "eks_access" {
  description = "Boolean to determine whether the EKS cluster is accessible"
  type        = bool
  default     = false
}

variable "deploy_compute_type" {
  description = "Compute type for the deploy stage"
  type        = string
  default     = "BUILD_GENERAL1_SMALL"
}

variable "deploy_image" {
  description = "Docker image for the deploy stage"
  type        = string
  default     = "aws/codebuild/amazonlinux-x86_64-standard:5.0"
}

variable "deploy_environment_type" {
  description = "Deploy environment type"
  type        = string
  default     = "LINUX_CONTAINER"
}

variable "deploy_privileged_mode" {
  description = "Whether the deploy stage should run in privileged mode"
  type        = bool
  default     = false
}

variable "deploy_environment_variables" {
  description = "Environment variables for the deploy stage"
  type        = list(map(string))
  default     = []
}

variable "deploy_vpc_config" {
  description = "VPC configuration for the deploy stage"
  type = object({
    vpc_id             = string
    subnets            = list(string)
    security_group_ids = list(string)
  })
  default = null
}

variable "deployspec_file" {
  description = "Buildspec file for the deploy stage"
  type        = string
  default     = "deployspec.yml"
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
