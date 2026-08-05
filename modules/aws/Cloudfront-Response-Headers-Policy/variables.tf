# -------------------------------------------------------------------------------------
#
# Copyright (c) 2026, WSO2 LLC. (https://www.wso2.com) All Rights Reserved.
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
  description = "Unique name for the response headers policy."
  type        = string
}

variable "comment" {
  description = "Comment describing the policy."
  type        = string
  default     = null
}

# --- Security headers (each sub-block is optional; omit to leave that header unmanaged) ------

variable "strict_transport_security" {
  description = "HSTS. Set null to omit."
  type = object({
    access_control_max_age_sec = number
    include_subdomains         = optional(bool, false)
    preload                    = optional(bool, false)
    override                   = optional(bool, true)
  })
  default = null
}

variable "content_type_options_override" {
  description = "When set, emit X-Content-Type-Options: nosniff with this override flag. Set null to omit."
  type        = bool
  default     = null
}

variable "frame_options" {
  description = "X-Frame-Options. frame_option must be DENY or SAMEORIGIN. Set null to omit."
  type = object({
    frame_option = string
    override     = optional(bool, true)
  })
  default = null

  validation {
    condition     = var.frame_options == null || contains(["DENY", "SAMEORIGIN"], try(var.frame_options.frame_option, ""))
    error_message = "frame_options.frame_option must be DENY or SAMEORIGIN."
  }
}

variable "referrer_policy" {
  description = "Referrer-Policy. Set null to omit."
  type = object({
    referrer_policy = string
    override        = optional(bool, true)
  })
  default = null
}

variable "xss_protection" {
  description = "X-XSS-Protection. Set null to omit."
  type = object({
    protection = bool
    mode_block = optional(bool, true)
    override   = optional(bool, true)
    report_uri = optional(string)
  })
  default = null
}

variable "content_security_policy" {
  description = "Content-Security-Policy. Prefer setting per-host CSP in a CloudFront Function; use this only for a single static CSP. Set null to omit."
  type = object({
    content_security_policy = string
    override                = optional(bool, true)
  })
  default = null
}

variable "custom_headers" {
  description = "Additional custom response headers. Map of header name -> { value, override }."
  type = map(object({
    value    = string
    override = optional(bool, true)
  }))
  default = {}
}
