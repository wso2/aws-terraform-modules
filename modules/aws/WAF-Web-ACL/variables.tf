# -------------------------------------------------------------------------------------
#
# Copyright (c) 2025, WSO2 LLC. (https://www.wso2.com) All Rights Reserved.
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

variable "name" {
  description = "Name of the WAF ACL"
  type        = string
}

variable "scope" {
  description = "The scope of the WAF ACL. Valid values are REGIONAL or CLOUDFRONT"
  type        = string
}

variable "description" {
  description = "The description of the WAF ACL"
  type        = string
}

variable "cloudwatch_metrics_enabled" {
  description = "Whether the associated resource sends metrics to CloudWatch"
  type        = bool
  default     = true
}

variable "cloudwatch_metric_name" {
  description = "The name of the CloudWatch metric"
  type        = string
  default     = "WAFACL"
}

variable "sampled_requests_enabled" {
  description = "Whether AWS WAF should store a sampling of the web requests that match the rules"
  type        = string
}

variable "default_action" {
  description = "The action that you want AWS WAF to take when a request doesn't match the criteria specified in any of the rules that are associated with the web ACL"
  type = object({
    type = string
    insert_header = optional(object({
      name  = string
      value = string
    }))
    custom_response_body_key = optional(string)
    response_code            = optional(number)
    response_header = optional(object({
      name  = string
      value = string
    }))
  })
}

variable "custom_response_body" {
  description = "The custom response to send (for example, custom page) when a request is blocked"
  type = map(object({
    content_type = string
    content      = string
    key          = string
  }))
  default = {}
}

variable "rules" {
  description = "The rules to associate with the web ACL"
  type = map(object({
    name                       = string
    priority                   = number
    cloudwatch_metrics_enabled = bool
    cloudwatch_metric_name     = string
    sampled_requests_enabled   = bool
    action = object({
      type = string
      insert_header = optional(object({
        name  = string
        value = string
      }))
      custom_response_body_key = optional(string)
      response_code            = optional(number)
      response_header = optional(object({
        name  = string
        value = string
      }))
    })
    override_action = optional(object({
      type = string
    }))
  }))
}

variable "tags" {
  description = "A map of tags to assign to the resource"
  type        = map(string)
  default     = {}
}
