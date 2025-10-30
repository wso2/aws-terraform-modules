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

variable "scheduled_action_name" {
  description = "Scheduled action name"
  type        = string
}

variable "autoscaling_group_name" {
  description = "Name of the Auto Scaling group"
  type        = string
}

variable "min_size" {
  description = "Min Size"
  type        = number
}

variable "max_size" {
  description = "Max Size"
  type        = number
}


variable "desired_size" {
  description = "Desired Size"
  type        = number
}

variable "recurrence_cron" {
  description = "Recurrence Cron"
  type        = string
}

variable "cron_time_zone" {
  description = "Cron Time Zone"
  type        = string
}