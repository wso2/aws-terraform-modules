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

variable "dns_name" {
  description = "The DNS name of the origin"
  type        = string
}

variable "origin_id" {
  description = "The origin ID"
  type        = string
  default     = "myOriginID"
}

variable "origin_protocol_policy" {
  description = "The origin protocol policy"
  type        = string
  default     = "https-only"
}

variable "origin_ssl_protocols" {
  description = "The SSL protocols for the origin"
  type        = list(string)
  default     = ["TLSv1.2"]
}

variable "enabled" {
  description = "Whether the distribution is enabled"
  type        = bool
  default     = true
}

variable "is_ipv6_enabled" {
  description = "Whether the distribution is IPv6 enabled"
  type        = bool
  default     = true
}

variable "comment" {
  description = "Comment for the distribution"
  type        = string
  default     = "CloudFront distribution"
}

variable "allowed_methods" {
  description = "List of allowed methods for the default cache behavior"
  type        = list(string)
  default     = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
}

variable "cached_methods" {
  description = "List of cached methods for the default cache behavior"
  type        = list(string)
  default     = ["GET", "HEAD"]
}

variable "viewer_protocol_policy" {
  description = "Viewer protocol policy for the default cache behavior"
  type        = string
  default     = "redirect-to-https"
}

variable "min_ttl" {
  description = "Minimum TTL for the default cache behavior"
  type        = number
  default     = 0
}

variable "default_ttl" {
  description = "Default TTL for the default cache behavior"
  type        = number
  default     = 3600
}

variable "max_ttl" {
  description = "Maximum TTL for the default cache behavior"
  type        = number
  default     = 86400
}

variable "geo_restriction_type" {
  description = "Type of geo restriction"
  type        = string
  default     = "none"
}

variable "geo_restriction_locations" {
  description = "List of locations for geo restriction"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Tags for the distribution"
  type        = map(string)
}

variable "web_acl_id" {
  description = "The ID of the AWS WAF web ACL associated with this distribution"
  type        = string
  default     = null
}

variable "ordered_cache_behaviors" {
  description = "List of ordered cache behaviors"
  type = list(object({
    path_pattern             = string
    allowed_methods          = list(string)
    cached_methods           = list(string)
    target_origin_id         = string
    viewer_protocol_policy   = string
    compress                 = string
    cache_policy_id          = string
    origin_request_policy_id = string
  }))
  default = []
}

variable "log_bucket_name" {
  description = "The S3 bucket name for CloudFront access logs (e.g., mybucket.s3.amazonaws.com)"
  type        = string
}

variable "log_include_cookies" {
  description = "Specifies whether you want CloudFront to include cookies in access logs"
  type        = bool
  default     = false
}

variable "log_prefix" {
  description = "An optional string that you want CloudFront to prefix to the access log filenames for this distribution"
  type        = string
  default     = null
}
