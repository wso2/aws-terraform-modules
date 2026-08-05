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

resource "aws_networkfirewall_firewall" "networkfirewall_firewall" {
  name                = join("-", [var.project, var.application, var.environment, var.region, "nfw"])
  description         = var.description
  firewall_policy_arn = aws_networkfirewall_firewall_policy.networkfirewall_firewall_policy.arn
  vpc_id              = var.vpc_id

  firewall_policy_change_protection = var.firewall_policy_change_protection
  subnet_change_protection          = var.subnet_change_protection

  dynamic "subnet_mapping" {
    for_each = toset(var.subnet_mapping)

    content {
      subnet_id = subnet_mapping.value
    }
  }

  tags = var.tags
}

resource "aws_networkfirewall_firewall_policy" "networkfirewall_firewall_policy" {
  name = join("-", [var.project, var.application, var.environment, var.region, "nfw-policy"])

  firewall_policy {
    stateless_default_actions          = ["aws:${var.stateless_default_actions}"]
    stateless_fragment_default_actions = ["aws:${var.stateless_fragment_default_actions}"]
    stateful_default_actions           = var.enable_strict_order ? var.stateful_default_actions : null

    #Stateless Rule Group Reference
    dynamic "stateless_rule_group_reference" {
      for_each = local.this_stateless_group_arn
      content {
        # Priority is sequentially as per index in stateless_rule_group list
        priority     = index(local.this_stateless_group_arn, stateless_rule_group_reference.value) + 1
        resource_arn = stateless_rule_group_reference.value
      }
    }

    dynamic "stateful_engine_options" {
      for_each = var.enable_strict_order ? [1] : []
      content {
        rule_order = "STRICT_ORDER"
      }
    }

    # Custom Suricata + domain rule groups — priority 1..N, evaluated FIRST.
    # Lower number = evaluated first in strict order.
    dynamic "stateful_rule_group_reference" {
      for_each = local.this_stateful_group_arn
      content {
        priority     = var.enable_strict_order ? index(local.this_stateful_group_arn, stateful_rule_group_reference.value) + 1 : null
        resource_arn = stateful_rule_group_reference.value
      }
    }

    # AWS Managed Rule Groups — priority N+1..N+M, evaluated after custom
    # Suricata/domain groups but BEFORE the fivetuple catch-all. Optional
    # DROP_TO_ALERT override for logging-only mode.
    dynamic "stateful_rule_group_reference" {
      for_each = var.aws_managed_rule_group
      content {
        priority     = var.enable_strict_order ? length(local.this_stateful_group_arn) + index(var.aws_managed_rule_group, stateful_rule_group_reference.value) + 1 : null
        resource_arn = stateful_rule_group_reference.value.arn
        dynamic "override" {
          for_each = stateful_rule_group_reference.value.override_action != null ? [1] : []
          content {
            action = stateful_rule_group_reference.value.override_action
          }
        }
      }
    }

    # 5-tuple catch-all rule groups — priority N+M+1..N+M+K, evaluated LAST.
    # This is where pass-all catch-alls belong: they only match traffic that
    # none of the custom or AWS-managed drop groups above claimed. Keeps the
    # enforced tier effective while still allowing default-deny + drop_strict
    # to be set as stateful_default_actions without dropping legitimate traffic.
    dynamic "stateful_rule_group_reference" {
      for_each = local.this_stateful_group_arn_catchall
      content {
        priority     = var.enable_strict_order ? length(local.this_stateful_group_arn) + length(var.aws_managed_rule_group) + index(local.this_stateful_group_arn_catchall, stateful_rule_group_reference.value) + 1 : null
        resource_arn = stateful_rule_group_reference.value
      }
    }
  }
  tags = merge(var.tags)

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_cloudwatch_log_group" "nfw_cloudwatch_log_group" {
  for_each = try(var.logging_config, {})
  name     = "${var.log_group_name_prefix}/${each.key}"

  tags = merge(var.tags)

  retention_in_days = each.value.retention_in_days
}

resource "aws_networkfirewall_logging_configuration" "networkfirewall_logging_configuration" {
  count        = try(length(var.logging_config), 0) > 0 ? 1 : 0
  firewall_arn = aws_networkfirewall_firewall.networkfirewall_firewall.arn
  logging_configuration {
    dynamic "log_destination_config" {
      for_each = var.logging_config
      content {
        log_destination = {
          logGroup = aws_cloudwatch_log_group.nfw_cloudwatch_log_group[log_destination_config.key].name
        }
        log_destination_type = "CloudWatchLogs"
        log_type             = upper(log_destination_config.key)
      }

    }
  }
}
