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

variable "topic_name" {
  description = "The name of the SNS topic"
}

variable "subscribers" {
  description = "A list of subscribers for the SNS topic"
  type        = list(object({
    protocol = string
    endpoint = string
    raw_message_delivery = optional(bool, false)
    filter_policy = optional(string)
    filter_policy_scope = optional(string, "MessageAttributes")
    endpoint_auto_confirms = optional(bool, false)
  }))
}
