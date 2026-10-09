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

variable "statement_id" {
  description = "Unique statement identifier for this permission"
  type        = string
}

variable "action" {
  description = "The AWS Lambda action to allow, e.g. lambda:InvokeFunction"
  type        = string
  default     = "lambda:InvokeFunction"
}

variable "function_name" {
  description = "Name or ARN of the Lambda function to grant the permission on"
  type        = string
}

variable "principal" {
  description = "The principal who is getting the permission, e.g. events.amazonaws.com"
  type        = string
}

variable "source_arn" {
  description = "ARN of the source triggering the invocation, e.g. a CloudWatch/EventBridge rule ARN"
  type        = string
  default     = null
}

variable "source_account" {
  description = "AWS account ID of the source owner, used for S3/cross-account triggers"
  type        = string
  default     = null
}

variable "qualifier" {
  description = "Lambda alias or version to invoke, if restricting the permission to a specific qualifier"
  type        = string
  default     = null
}

variable "event_source_token" {
  description = "Event source token, required for Alexa Skills Kit triggers"
  type        = string
  default     = null
}
