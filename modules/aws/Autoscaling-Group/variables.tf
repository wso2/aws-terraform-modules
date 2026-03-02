# -------------------------------------------------------------------------------------
#
# Copyright (c) 2026, WSO2 LLC. (http://www.wso2.com). All Rights Reserved.
#
# This software is the property of WSO2 LLC. and its suppliers, if any.
# Dissemination of any information or reproduction of any material contained
# herein in any form is strictly forbidden, unless permitted by WSO2 expressly.
# You may not alter or remove any copyright or other notice from copies of this content.
#
# --------------------------------------------------------------------------------------

variable "project" {
  description = "The name of the project to which the launch template belongs"
  type        = string
}

variable "environment" {
  description = "The environment to which the launch template belongs (e.g., dev, staging, prod)"
  type        = string
}

variable "application" {
  description = "The name of the application to which the launch template belongs"
  type        = string
}

variable "region" {
  description = "The AWS region in which to create the launch template"
  type        = string
}

variable "name" {
  description = "The name of the launch template"
  type        = string
}

variable "max_size" {
  description = "The maximum size of the Auto Scaling group"
  type        = number
}

variable "min_size" {
  description = "The minimum size of the Auto Scaling group"
  type        = number
}

variable "desired_size" {
  description = "The desired size of the Auto Scaling group"
  type        = number
}

variable "vpc_zone_identifier" {
  description = "The subnet IDs for the Auto Scaling group"
  type        = list(string)
}

variable "target_group_arns" {
  description = "The ARNs of the target groups to associate with the Auto Scaling group"
  type        = list(string)
}

variable "health_check_type" {
  description = "The service to use for the health checks. The valid values are: EC2 and ELB"
  type        = string
}

variable "health_check_grace_period" {
  description = "The amount of time, in seconds, that Auto Scaling waits before checking the health status of an EC2 instance that has come into service"
  type        = number
}

variable "default_cooldown" {
  description = "The amount of time, in seconds, after a scaling activity completes before another scaling activity can start"
  type        = number
}

variable "launch_template_id" {
  description = "The ID of the launch template to use to launch EC2 instances"
  type        = string
}

variable "termination_policies" {
  description = "A list of termination policies used to select the instance to terminate when scaling in"
  type        = list(string)
}

variable "wait_for_capacity_timeout" {
  description = "The amount of time, in seconds, to wait for a capacity update before timing out"
  type        = string
  default     = "10m"
}

variable "protect_from_scale_in" {
  description = "Indicates whether newly launched instances are protected from termination by Auto Scaling when scaling in"
  type        = bool
  default     = false
}

variable "min_healthy_percentage" {
  description = "The minimum percentage of healthy instances that must be maintained during an instance refresh"
  type        = number
  default     = 66
}

variable "tags" {
  description = "A map of tags to apply to the Auto Scaling group"
  type = list(
    object({
      key                 = string
      value               = string
      propagate_at_launch = optional(bool, true)
    })
  )
}
