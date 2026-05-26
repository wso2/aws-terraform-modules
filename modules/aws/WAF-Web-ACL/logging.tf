# -------------------------------------------------------------------------------------
#
# Copyright (c) 2026, WSO2 LLC (http://www.wso2.com). All Rights Reserved.
#
# This software is the property of WSO2 LLC and its suppliers, if any.
# Dissemination of any information or reproduction of any material contained
# herein in any form is strictly forbidden, unless permitted by WSO2 expressly.
# You may not alter or remove any copyright or other notice from copies of this content.
#
# --------------------------------------------------------------------------------------

# WAF logging configuration.
# Only created when enable_logging = true.
#
# The logging_filter limits log volume by applying per-request action filters:
#   - default_behavior: DROP — requests that match no filter are not logged (i.e., normal ALLOW traffic is excluded)
#   - BLOCK: requests blocked by WAF rules
#   - EXCLUDED_AS_COUNT: managed rule group matches that were overridden to count mode.
#     When a managed rule group has override_action = count, matched rules appear in
#     WAF logs with action EXCLUDED_AS_COUNT rather than COUNT. These are the requests
#     that drive the hub_waf_counted_requests CloudWatch alarm.
#
# Both filter lists are driven by var.log_filter_keep_actions so callers can
# adjust the set of logged actions without modifying this file.
resource "aws_wafv2_web_acl_logging_configuration" "waf" {
  count = var.enable_logging ? 1 : 0

  log_destination_configs = var.log_destination_arns
  resource_arn            = aws_wafv2_web_acl.web_acl.arn

  logging_filter {
    default_behavior = var.log_filter_default_behavior

    dynamic "filter" {
      for_each = var.log_filter_keep_actions
      content {
        behavior    = "KEEP"
        requirement = "MEETS_ANY"
        condition {
          action_condition {
            action = filter.value
          }
        }
      }
    }
  }
}
