# -------------------------------------------------------------------------------------
#
# Copyright (c) 2023, WSO2 LLC. (http://www.wso2.com). All Rights Reserved.
#
# This software is the property of WSO2 LLC. and its suppliers, if any.
# Dissemination of any information or reproduction of any material contained
# herein in any form is strictly forbidden, unless permitted by WSO2 expressly.
# You may not alter or remove any copyright or other notice from copies of this content.
#
# --------------------------------------------------------------------------------------

variable "firewall_arn" {
  description = "The ARN of the firewall"
  type        = string
}
variable "log_destination_configs" {
  description = "The logging configuration"
  type = map(object({
    log_destination_type = string
    log_type             = string
    log_group            = optional(string)
    delivery_stream      = optional(string)
    prefix               = optional(string)
    bucket_name          = optional(string)
  }))
}
