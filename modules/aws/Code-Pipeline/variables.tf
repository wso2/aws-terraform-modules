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

variable "integration_bucket_name" {
  description = "S3 bucket name for CodePipeline artifact store"
  type        = string
}

variable "pipeline_role_arn" {
  description = "IAM Role ARN for CodePipeline"
  type        = string
}

variable "pipeline_name" {
  type        = string
  description = "Name of the CodePipeline"
  default     = "integration-pipeline"
}

variable "stages" {
  description = "List of stages with actions"
  type = list(object({
    name    = string
    actions = list(object({
      name             = string
      category         = string
      owner            = string
      provider         = string
      version          = string
      input_artifacts  = optional(list(string))
      output_artifacts = optional(list(string))
      configuration    = map(string)
    }))
  }))
}
