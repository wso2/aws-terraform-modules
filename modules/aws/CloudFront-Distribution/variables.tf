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

variable "enabled" {
  description = "Whether the distribution is enabled"
  type        = bool
  default     = true
}

variable "is_ipv6_enabled" {
  description = "Whether IPv6 is enabled"
  type        = bool
  default     = true
}

variable "comment" {
  description = "Comment for the distribution"
  type        = string
  default     = ""
}

variable "web_acl_id" {
  description = "WAF Web ACL ID"
  type        = string
  default     = null
}

variable "aliases" {
  description = "List of CNAME aliases"
  type        = list(string)
  default     = []
}

variable "origins" {
  description = "List of origin configurations"
  type = list(object({
    domain_name = string
    origin_id   = string
    custom_origin_config = optional(object({
      http_port              = number
      https_port             = number
      origin_protocol_policy = string
      origin_ssl_protocols   = list(string)
    }))
    s3_origin_config = optional(object({
      origin_access_identity = string
    }))
  }))
}

variable "logging_config" {
  description = "Logging configuration"
  type = object({
    bucket          = string
    include_cookies = bool
    prefix          = string
  })
  default = null
}

variable "default_cache_behavior" {
  description = "Default cache behavior configuration"
  type = object({
    allowed_methods  = list(string)
    cached_methods   = list(string)
    target_origin_id = string
    forwarded_values = optional(object({
      query_string    = bool
      cookies_forward = string
    }))
    viewer_protocol_policy   = string
    min_ttl                  = number
    default_ttl              = number
    max_ttl                  = number
    cache_policy_id          = optional(string)
    origin_request_policy_id = optional(string)
  })
}

variable "ordered_cache_behaviors" {
  description = "Ordered cache behaviors"
  type = list(object({
    path_pattern             = string
    allowed_methods          = list(string)
    cached_methods           = list(string)
    target_origin_id         = string
    viewer_protocol_policy   = string
    compress                 = bool
    cache_policy_id          = optional(string)
    origin_request_policy_id = optional(string)
  }))
  default = []
}

variable "geo_restriction_type" {
  description = "Geo restriction type (none, whitelist, blacklist)"
  type        = string
  default     = "none"
}

variable "geo_restriction_locations" {
  description = "List of country codes for geo restriction"
  type        = list(string)
  default     = []
}

variable "acm_certificate_arn" {
  description = "ACM certificate ARN for custom SSL"
  type        = string
  default     = null
}

variable "minimum_protocol_version" {
  description = "Minimum TLS protocol version"
  type        = string
  default     = "TLSv1.2_2021"
}

variable "tags" {
  description = "Tags to apply to the distribution"
  type        = map(string)
  default     = {}
}

variable "dependencies" {
  description = "List of resources this distribution depends on"
  type        = list(any)
  default     = []
}
