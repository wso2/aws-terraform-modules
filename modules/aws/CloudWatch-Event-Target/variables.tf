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
