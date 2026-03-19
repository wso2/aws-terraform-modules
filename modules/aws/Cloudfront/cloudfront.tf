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

resource "aws_cloudfront_distribution" "cloudfront_distribution" {
  origin {
    domain_name = var.dns_name
    origin_id   = var.origin_id

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = var.origin_protocol_policy
      origin_ssl_protocols   = var.origin_ssl_protocols
    }

    dynamic "origin_shield" {
      for_each = var.origin_shield_enabled ? [1] : []
      content {
        enabled              = true
        origin_shield_region = var.origin_shield_region
      }
    }
  }

  enabled         = var.enabled
  is_ipv6_enabled = var.is_ipv6_enabled
  comment         = var.comment

  aliases = var.aliases

  dynamic "logging_config" {
    for_each = var.log_bucket_name != null ? [1] : []
    content {
      bucket          = var.log_bucket_name
      include_cookies = var.log_include_cookies
      prefix          = var.log_prefix
    }
  }

  default_cache_behavior {
    cache_policy_id            = var.cache_policy_id
    response_headers_policy_id = var.response_headers_policy_id
    origin_request_policy_id   = var.origin_request_policy_id
    allowed_methods            = var.allowed_methods
    cached_methods             = var.cached_methods
    target_origin_id           = var.origin_id

    dynamic "forwarded_values" {
      for_each = var.cache_policy_id == null ? [1] : []
      content {
        query_string = true
        cookies {
          forward = "none"
        }
      }
    }

    viewer_protocol_policy = var.viewer_protocol_policy
    min_ttl                = var.min_ttl
    default_ttl            = var.default_ttl
    max_ttl                = var.max_ttl
  }

  dynamic "ordered_cache_behavior" {
    for_each = var.ordered_cache_behaviors
    content {
      path_pattern             = ordered_cache_behavior.value.path_pattern
      target_origin_id         = ordered_cache_behavior.value.target_origin_id
      compress                 = ordered_cache_behavior.value.compress
      viewer_protocol_policy   = ordered_cache_behavior.value.viewer_protocol_policy
      allowed_methods          = ordered_cache_behavior.value.allowed_methods
      cached_methods           = ordered_cache_behavior.value.cached_methods
      cache_policy_id          = ordered_cache_behavior.value.cache_policy_id
      origin_request_policy_id = ordered_cache_behavior.value.origin_request_policy_id

      dynamic "forwarded_values" {
        for_each = ordered_cache_behavior.value.cache_policy_id == null ? [1] : []
        content {
          query_string = true
          cookies {
            forward = "none"
          }
        }
      }
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = var.geo_restriction_type
      locations        = var.geo_restriction_locations
    }
  }

  tags = var.tags

  viewer_certificate {
    cloudfront_default_certificate = var.cloudfront_default_certificate
    acm_certificate_arn            = var.cloudfront_acm_certificate_arn
    ssl_support_method             = var.cloudfront_acm_certificate_arn != null ? var.cloudfront_ssl_support_method : null
    minimum_protocol_version       = var.minimum_protocol_version
  }

  web_acl_id = var.web_acl_id

  lifecycle {
    precondition {
      condition     = var.cloudfront_default_certificate == false ? var.cloudfront_acm_certificate_arn != null : true
      error_message = "cloudfront_acm_certificate_arn must be provided when cloudfront_default_certificate is false."
    }
    precondition {
      condition     = var.cloudfront_default_certificate == true ? var.cloudfront_acm_certificate_arn == null : true
      error_message = "cloudfront_acm_certificate_arn must not be set when cloudfront_default_certificate is true."
    }
  }
}
