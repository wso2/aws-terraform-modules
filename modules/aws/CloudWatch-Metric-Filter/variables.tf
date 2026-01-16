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

variable "name" {
  description = "The name of the metric filter"
  type        = string
}

variable "log_group_name" {
  description = "The name of the log group to create the metric filter on"
  type        = string
}

variable "pattern" {
  description = "A valid CloudWatch Logs filter pattern for extracting metric data"
  type        = string
}

variable "metric_name" {
  description = "The name of the CloudWatch metric"
  type        = string
}

variable "metric_namespace" {
  description = "The destination namespace of the CloudWatch metric"
  type        = string
}

variable "metric_value" {
  description = "The value to publish to the CloudWatch metric"
  type        = string
  default     = "1"
}

variable "metric_unit" {
  description = "The unit to assign to the metric"
  type        = string
  default     = "Count"
}

variable "metric_default_value" {
  description = "The value to emit when a filter pattern does not match a log event"
  type        = number
  default     = null
}

variable "metric_dimensions" {
  description = "Map of dimensions for the metric"
  type        = map(string)
  default     = {}
}
