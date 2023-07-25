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

variable "name" {
  type        = string
  description = "Name of the WAF ACL"
}
variable "scope" {
  type        = string
  description = "The scope of the WAF ACL. Valid values are REGIONAL or CLOUDFRONT"
}
variable "description" {
  type        = string
  description = "The description of the WAF ACL"
}
variable "cloudwatch_metrics_enabled" {
  type        = bool
  description = "Whether the associated resource sends metrics to CloudWatch"
  default     = true
}
variable "cloudwatch_metric_name" {
  type        = string
  description = "The name of the CloudWatch metric"
  default     = "WAFACL"
}
variable "sampled_requests_enabled" {
  type        = string
  description = "Whether AWS WAF should store a sampling of the web requests that match the rules"
}
variable "default_action" {
  type = map(object({
    type = string
    insert_header = optional(map(object({
      name  = string
      value = string
    })))
    custom_response_body_key = optional(string)
    response_code            = optional(string)
    response_header = optional(map(object({
      name  = string
      value = string
    })))
  }))
  description = "The action that you want AWS WAF to take when a request doesn't match the criteria specified in any of the rules that are associated with the web ACL"
}
variable "custom_response_body" {
  type = map(object({
    content_type = string
    content      = string
    key          = string
  }))
  description = "The custom response to send (for example, custom page) when a request is blocked"
  default     = null
}
variable "rules" {
  type = map(object({
    name                       = string
    priority                   = number
    cloudwatch_metrics_enabled = bool
    cloudwatch_metric_name     = string
    sampled_requests_enabled   = string
    action = map(object({
      type = string
      insert_header = optional(map(object({
        name  = string
        value = string
      })))
      custom_response_body_key = optional(string)
      response_code            = optional(string)
      response_header = optional(map(object({
        name  = string
        value = string
      })))
    }))
    override_action = optional(map(object({
      type = string
    })))
  }))

}
variable "tags" {
  type        = map(string)
  description = "A map of tags to assign to the resource"
  default     = {}
}
