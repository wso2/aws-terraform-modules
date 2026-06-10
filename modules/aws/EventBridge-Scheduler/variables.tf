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

variable "environment" {
  description = "Name of the environment"
  type        = string
}

variable "region" {
  description = "AWS region to deploy the schedule"
  type        = string
}

variable "application" {
  description = "Name of the application"
  type        = string
}

variable "schedule_name" {
  description = "Identifier for the schedule (used in the generated name)"
  type        = string
}

variable "group_name" {
  description = "Name of the schedule group the schedule belongs to"
  type        = string
  default     = "default"
}

variable "state" {
  description = "State of the schedule (ENABLED or DISABLED)"
  type        = string
  default     = "ENABLED"
}

variable "schedule_expression" {
  description = "The scheduling expression (e.g. cron(30 3 ? * MON *) or rate(7 days))"
  type        = string
}

variable "schedule_expression_timezone" {
  description = "Timezone in which the schedule expression is evaluated"
  type        = string
  default     = "UTC"
}

variable "flexible_time_window_mode" {
  description = "Flexible time window mode (OFF or FLEXIBLE)"
  type        = string
  default     = "OFF"
}

variable "maximum_window_in_minutes" {
  description = "Maximum window, in minutes, the schedule can be invoked within. Required when flexible_time_window_mode is FLEXIBLE"
  type        = number
  default     = null
}

variable "target_arn" {
  description = "ARN of the target the schedule invokes (e.g. a Lambda function ARN)"
  type        = string
}

variable "role_arn" {
  description = "ARN of the IAM role the scheduler assumes to invoke the target"
  type        = string
}

variable "input" {
  description = "JSON payload passed to the target on invocation"
  type        = string
  default     = "{}"
}
