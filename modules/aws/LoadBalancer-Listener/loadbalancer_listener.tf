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

resource "aws_lb_listener" "lb_listener" {
  load_balancer_arn = var.load_balancer_arn
  certificate_arn   = var.certificate_arn
  alpn_policy       = var.alpn_policy
  port              = var.port
  protocol          = var.protocol
  ssl_policy        = var.ssl_policy
  tags              = var.default_tags

  default_action {
    type = var.default_action_type

    target_group_arn = var.target_group_arn

    dynamic "forward" {
      for_each = var.default_action_type == "forward" && var.forward_rule != null ? try([var.forward_rule], []) : []
      content {

        dynamic "target_group" {
          for_each = forward.value.target_groups != null ? forward.value.target_groups : []
          content {
            arn    = target_group.value.target_group_arn
            weight = target_group.value.weight
          }
        }
        dynamic "stickiness" {
          for_each = forward.value.stickiness != null ? [forward.value.stickiness] : []
          content {
            enabled  = try([stickiness.value.enabled], null)
            duration = try([stickiness.value.duration], null)
          }
        }
      }
    }

    dynamic "fixed_response" {
      for_each = var.default_action_type == "fixed_response" ? try([var.fixed_response_rule], []) : []
      content {
        message_body = fixed_response.value.message_body
        status_code  = fixed_response.value.status_code
        content_type = fixed_response.value.content_type
      }
    }

    dynamic "redirect" {
      for_each = var.default_action_type == "redirect" ? try([var.redirect_rule], []) : []
      content {
        query       = redirect.value.query
        status_code = redirect.value.status_code
        port        = redirect.value.port
        host        = redirect.value.host
        path        = redirect.value.path
        protocol    = redirect.value.protocol
      }
    }

  }
}

resource "aws_lb_listener_rule" "lb_listener_rule" {
  for_each = var.rules

  listener_arn = aws_lb_listener.lb_listener.arn

  priority = each.value.priority

  # Add a single action
  action {
    type             = each.value.action_type
    target_group_arn = each.value.target_group_arn

    dynamic "fixed_response" {
      for_each = each.value.action_type == "fixed_response" ? try([each.value.fixed_response], []) : []

      content {
        message_body = fixed_response.value.message_body
        content_type = fixed_response.value.content_type
        status_code  = fixed_response.value.status_code
      }
    }

    dynamic "forward" {
      for_each = each.value.action_type == "forward" && each.value.action_type != null ? try([each.value.forward], []) : []

      content {
        dynamic "target_group" {
          for_each = forward.value.target_groups != null ? forward.value.target_groups : []

          content {
            arn    = target_group.value.arn
            weight = target_group.value.weight
          }
        }

        dynamic "stickiness" {
          for_each = forward.value.stickiness != null ? [forward.value.stickiness] : []

          content {
            enabled  = try([stickiness.value.enabled], null)
            duration = try([stickiness.value.duration], null)
          }
        }
      }
    }

    dynamic "redirect" {
      for_each = each.value.action_type == "redirect" ? try([each.value.redirect], []) : []

      content {
        status_code = redirect.value.status_code
        host        = redirect.value.host
        path        = redirect.value.path
        port        = redirect.value.port
        protocol    = redirect.value.protocol
        query       = redirect.value.query
      }
    }
  }

  dynamic "condition" {
    for_each = each.value.conditions

    content {
      dynamic "host_header" {
        for_each = try([condition.value.host_header], [])

        content {
          values = host_header.value.values
        }
      }

      dynamic "http_header" {
        for_each = try([condition.value.http_header], [])

        content {
          http_header_name = http_header.value.http_header_name
          values           = http_header.value.values
        }
      }

      dynamic "http_request_method" {
        for_each = try([condition.value.http_request_method], [])

        content {
          values = http_request_method.value.values
        }
      }

      dynamic "path_pattern" {
        for_each = try([condition.value.path_pattern], [])

        content {
          values = path_pattern.value.values
        }
      }

      dynamic "query_string" {
        for_each = try([condition.value.query_string], [])

        content {
          key   = try(query_string.value.key, null)
          value = query_string.value.value
        }
      }

      dynamic "source_ip" {
        for_each = try([condition.value.source_ip], [])

        content {
          values = source_ip.value.values
        }
      }
    }
  }

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [aws_lb_listener.lb_listener]
}
