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

variable "lambda_function_name" {
  description = "The name of the Lambda function"
  type        = string
}
variable "project" {
  description = "Name of the project"
  type        = string
}
variable "environment" {
  description = "Name of the environment"
  type        = string
}
variable "application" {
  description = "Name of the application"
  type        = string
}
variable "region" {
  description = "AWS region to deploy the Lambda function"
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
variable "cloudwatch_log_group_kms_key_id" {
  description = "KMS Key ID for encrypting CloudWatch log group"
  type        = string
  default     = null
}
