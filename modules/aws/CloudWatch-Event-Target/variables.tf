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

variable "rule" {
  description = "The name of the rule to associate with the target"
  type        = string
}

variable "target_id" {
  description = "The unique target assignment ID"
  type        = string
}

variable "arn" {
  description = "The Amazon Resource Name (ARN) of the target"
  type        = string
}

variable "role_arn" {
  description = "The Amazon Resource Name (ARN) of the IAM role to be used for this target when the rule is triggered"
  type        = string
  default     = null
}

variable "input" {
  description = "Valid JSON text passed to the target"
  type        = string
  default     = null
}

variable "input_path" {
  description = "The value of the JSONPath that is used for extracting part of the matched event when passing it to the target"
  type        = string
  default     = null
}

variable "run_command_targets" {
  description = "Parameters used when you are using the rule to invoke Amazon EC2 Run Command"
  type = object({
    key    = string
    values = list(string)
  })
  default = null
}

variable "ecs_target" {
  description = "Parameters used when you are using the rule to invoke Amazon ECS Task"
  type = object({
    task_definition_arn     = string
    task_count              = number
    launch_type             = string
    platform_version        = string
    group                   = string
    enable_ecs_managed_tags = bool
    enable_execute_command  = bool
  })
  default = null
}
