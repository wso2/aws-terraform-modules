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

resource "aws_wafv2_web_acl" "web_acl" {
  name        = var.name
  scope       = var.scope
  description = var.description

  tags = var.tags

  visibility_config {
    cloudwatch_metrics_enabled = var.cloudwatch_metrics_enabled
    metric_name                = var.cloudwatch_metric_name
    sampled_requests_enabled   = var.sampled_requests_enabled
  }

  default_action {
    dynamic "allow" {
      for_each = var.default_action.type == "allow" ? [1] : []
      content {
        dynamic "custom_request_handling" {
          for_each = var.default_action.insert_header != null ? [1] : []
          content {
            insert_header {
              name  = var.default_action.insert_header.name
              value = var.default_action.insert_header.value
            }
          }
        }
      }
    }
    dynamic "block" {
      for_each = var.default_action.type == "block" ? [1] : []
      content {
        dynamic "custom_response" {
          for_each = var.default_action.response_header != null ? [1] : []
          content {
            custom_response_body_key = var.default_action.custom_response_body_key
            response_code            = var.default_action.response_code
            response_header {
              name  = var.default_action.response_header.name
              value = var.default_action.response_header.value
            }
          }
        }
      }
    }
  }

  dynamic "custom_response_body" {
    for_each = var.custom_response_body != null ? tomap(var.custom_response_body) : {}

    content {
      content      = custom_response_body.value.content
      content_type = custom_response_body.value.content_type
      key          = custom_response_body.value.key
    }
  }

  dynamic "rule" {
    for_each = var.rules

    content {
      name     = rule.value.name
      priority = rule.value.priority
      action {
        dynamic "allow" {
          for_each = rule.value.action.type == "allow" ? [1] : []
          content {
            dynamic "custom_request_handling" {
              for_each = rule.value.action.insert_header == null ? [1] : []
              content {
                insert_header {
                  name  = rule.value.action.insert_header.name
                  value = rule.value.action.insert_header.value
                }
              }
            }
          }
        }
        dynamic "block" {
          for_each = rule.value.action.type == "block" ? [1] : []
          content {
            dynamic "custom_response" {
              for_each = rule.value.action.response_header == null ? [1] : []
              content {
                custom_response_body_key = rule.value.action.custom_response_body_key
                response_code            = rule.value.action.response_code
                response_header {
                  name  = rule.value.action.response_header.name
                  value = rule.value.action.response_header.value
                }
              }
            }
          }
        }
      }

      override_action {
        dynamic "count" {
          for_each = rule.value.override_action.type == "count" ? [1] : []
          content {}
        }
        dynamic "none" {
          for_each = rule.value.override_action.type == "none" ? [1] : []
          content {}
        }
      }

      statement {

      }
      visibility_config {
        cloudwatch_metrics_enabled = rule.value.cloudwatch_metrics_enabled
        metric_name                = rule.value.cloudwatch_metric_name
        sampled_requests_enabled   = rule.value.sampled_requests_enabled
      }
    }
  }
}
