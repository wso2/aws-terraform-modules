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

resource "aws_cloudfront_response_headers_policy" "policy" {
  name    = var.name
  comment = var.comment

  security_headers_config {
    dynamic "strict_transport_security" {
      for_each = var.strict_transport_security != null ? [var.strict_transport_security] : []
      content {
        access_control_max_age_sec = strict_transport_security.value.access_control_max_age_sec
        include_subdomains         = strict_transport_security.value.include_subdomains
        preload                    = strict_transport_security.value.preload
        override                   = strict_transport_security.value.override
      }
    }

    dynamic "content_type_options" {
      for_each = var.content_type_options_override != null ? [1] : []
      content {
        override = var.content_type_options_override
      }
    }

    dynamic "frame_options" {
      for_each = var.frame_options != null ? [var.frame_options] : []
      content {
        frame_option = frame_options.value.frame_option
        override     = frame_options.value.override
      }
    }

    dynamic "referrer_policy" {
      for_each = var.referrer_policy != null ? [var.referrer_policy] : []
      content {
        referrer_policy = referrer_policy.value.referrer_policy
        override        = referrer_policy.value.override
      }
    }

    dynamic "xss_protection" {
      for_each = var.xss_protection != null ? [var.xss_protection] : []
      content {
        protection = xss_protection.value.protection
        mode_block = xss_protection.value.mode_block
        override   = xss_protection.value.override
        report_uri = xss_protection.value.report_uri
      }
    }

    dynamic "content_security_policy" {
      for_each = var.content_security_policy != null ? [var.content_security_policy] : []
      content {
        content_security_policy = content_security_policy.value.content_security_policy
        override                = content_security_policy.value.override
      }
    }
  }

  dynamic "custom_headers_config" {
    for_each = length(var.custom_headers) > 0 ? [1] : []
    content {
      dynamic "items" {
        for_each = var.custom_headers
        content {
          header   = items.key
          value    = items.value.value
          override = items.value.override
        }
      }
    }
  }
}
