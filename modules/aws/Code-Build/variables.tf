# -------------------------------------------------------------------------------------
#
# Copyright (c) 2025, WSO2 LLC. (http://www.wso2.com). All Rights Reserved.
#
# This software is the property of WSO2 LLC. and its suppliers, if any.
# Dissemination of any information or reproduction of any material contained
# herein in any form is strictly forbidden, unless permitted by WSO2 expressly.
# You may not alter or remove any copyright or other notice from copies of this content.
#
# --------------------------------------------------------------------------------------

variable "project" {
  description = "Project name"
  type        = string
}
variable "description" {
  description = "Description of the CodeBuild project"
  type        = string
  default     = "CodeBuild project for CI/CD integration"
}
variable "build_name" {
  description = "Build name for the CodeBuild project"
  type        = string
}
variable "codebuild_role_arn" {
  description = "IAM Role ARN for CodeBuild"
  type        = string
}
variable "compute_type" {
  description = "Compute type for CodeBuild"
  type        = string
  default     = "BUILD_GENERAL1_SMALL"
}
variable "image" {
  description = "CodeBuild image"
  type        = string
  default     = "aws/codebuild/standard:7.0"
}
variable "environment_type" {
  description = "Environment type"
  type        = string
  default     = "LINUX_CONTAINER"
}
variable "privileged_mode" {
  description = "Enable Docker builds inside CodeBuild"
  type        = bool
  default     = true
}
variable "environment_variables" {
  description = "List of environment variables"
  type = list(object({
    name  = string
    value = string
    type  = optional(string)
  }))
  default = []
}
variable "tags" {
  description = "Tags for the project"
  type        = map(string)
  default     = {}
}
variable "artifacts" {
  description = "Artifact configuration for CodeBuild"
  type = object({
    type                   = string
    location               = optional(string)
    path                   = optional(string)
    namespace_type         = optional(string)
    packaging              = optional(string)
    name                   = optional(string)
    artifact_identifier    = optional(string)
    override_artifact_name = optional(bool)
    encryption_disabled    = optional(bool)
  })
  default = {
    type = "CODEPIPELINE"
  }
}
variable "codebuild_source" {
  description = "Source configuration for CodeBuild"
  type = object({
    type                = string
    location            = optional(string)
    buildspec           = optional(string)
    git_clone_depth     = optional(number)
    insecure_ssl        = optional(bool)
    report_build_status = optional(bool)

    auth = optional(object({
      type     = string
      resource = string
    }))

    git_submodules_config = optional(object({
      fetch_submodules = bool
    }))

    build_status_config = optional(object({
      context    = string
      target_url = string
    }))
  })
  default = {
    type      = "CODEPIPELINE"
    buildspec = "buildspec.yml"
  }
}
