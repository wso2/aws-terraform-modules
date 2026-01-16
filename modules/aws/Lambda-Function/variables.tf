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

variable "lambda_function_name" {
  type        = string
  description = "The name for the Lambda Function"
}

variable "lambda_function_abbreviation" {
  type        = string
  description = "The abbreviation for the Lambda Function resource name"
  default     = "lf"
}

variable "iam_role_abbreviation" {
  type        = string
  description = "The abbreviation for the IAM Role resource name"
  default     = "ir"
}

variable "iam_role_name" {
  description = "The name for the IAM Role"
  type        = string
}

variable "iam_policy_abbreviation" {
  type        = string
  description = "The abbreviation for the IAM Policy resource name"
  default     = "ip"
}

variable "iam_policy_name" {
  description = "The name for the IAM Policy"
  type        = string
}

variable "lambda_function_source_dir" {
  description = "Directory containing the Lambda function source code"
  type        = string
}
variable "lambda_function_source_file" {
  description = "The source file of the Lambda function"
  type        = string
}
variable "lambda_function_output_file" {
  description = "The output file for the Lambda function archive"
  type        = string
}
variable "runtime_version" {
  description = "The runtime version for the Lambda function"
  type        = string
}
variable "tags" {
  description = "Tags to be attached to the Lambda function"
  type        = map(string)
  default     = {}
}
variable "handler" {
  description = "Entrypoint to the function"
  type        = string
}

variable "filename" {
  description = "Path to the Lambda function ZIP file"
  type        = string
}

variable "function_name" {
  description = "Name of the Lambda function"
  type        = string
}

variable "iam_role_arn" {
  description = "IAM role ARN for the Lambda function"
  type        = string
}

variable "source_code_hash" {
  description = "Base64-encoded SHA256 hash of the ZIP file"
  type        = string
}

variable "runtime" {
  description = "Lambda runtime"
  type        = string
}

variable "timeout" {
  description = "Function timeout in seconds"
  type        = number
  default     = 3
}

variable "memory_size" {
  description = "Function memory size in MB"
  type        = number
  default     = 128
}

variable "environment_variables" {
  description = "Environment variables for the function"
  type        = map(string)
  default     = null
}


variable "permissions" {
  description = "Map of Lambda permissions"
  type = map(object({
    statement_id = string
    action       = string
    principal    = string
    source_arn   = optional(string)
  }))
  default = {}
}
