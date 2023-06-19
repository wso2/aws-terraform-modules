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

resource "aws_networkfirewall_rule_group" "suricata_stateful_group" {
  count = length(var.suricata_stateful_rule_group) > 0 ? length(var.suricata_stateful_rule_group) : 0
  type  = "STATEFUL"

  name        = var.suricata_stateful_rule_group[count.index]["name"]
  description = var.suricata_stateful_rule_group[count.index]["description"]
  capacity    = var.suricata_stateful_rule_group[count.index]["capacity"]

  rule_group {
    rules_source {
      rules_string = file(var.suricata_stateful_rule_group[count.index]["rules_file"])
    }

    dynamic "rule_variables" {
      for_each = [
        for b in lookup(var.suricata_stateful_rule_group[count.index], "rule_variables", {}) : b
        if length(b) > 1
      ]
      content {
        dynamic "ip_sets" {
          for_each = lookup(lookup(var.suricata_stateful_rule_group[count.index], "rule_variables", {}), "ip_sets", [])
          content {
            key = ip_sets.value["key"]
            ip_set {
              definition = ip_sets.value["ip_set"]
            }
          }
        }

        dynamic "port_sets" {
          for_each = lookup(lookup(var.suricata_stateful_rule_group[count.index], "rule_variables", {}), "port_sets", [])
          content {
            key = port_sets.value["key"]
            port_set {
              definition = port_sets.value["port_sets"]
            }
          }
        }
      }
    }


  }

  tags = merge(var.default_tags)
}

resource "aws_networkfirewall_rule_group" "domain_stateful_group" {
  count = length(var.domain_stateful_rule_group) > 0 ? length(var.domain_stateful_rule_group) : 0
  type  = "STATEFUL"

  name        = var.domain_stateful_rule_group[count.index]["name"]
  description = var.domain_stateful_rule_group[count.index]["description"]
  capacity    = var.domain_stateful_rule_group[count.index]["capacity"]

  rule_group {
    dynamic "rule_variables" {
      for_each = [
        for b in lookup(var.domain_stateful_rule_group[count.index], "rule_variables", {}) : b
        if length(b) > 1
      ]
      content {
        dynamic "ip_sets" {
          for_each = lookup(lookup(var.domain_stateful_rule_group[count.index], "rule_variables", {}), "ip_sets", [])
          content {
            key = ip_sets.value["key"]
            ip_set {
              definition = ip_sets.value["ip_set"]
            }
          }
        }

        dynamic "port_sets" {
          for_each = lookup(lookup(var.domain_stateful_rule_group[count.index], "rule_variables", {}), "port_sets", [])
          content {
            key = port_sets.value["key"]
            port_set {
              definition = port_sets.value["port_sets"]
            }
          }
        }
      }
    }

    rules_source {
      rules_source_list {
        generated_rules_type = var.domain_stateful_rule_group[count.index]["actions"]
        target_types         = var.domain_stateful_rule_group[count.index]["protocols"]
        targets              = var.domain_stateful_rule_group[count.index]["domain_list"]
      }
    }
  }

  tags = merge(var.default_tags)
}

resource "aws_networkfirewall_rule_group" "fivetuple_stateful_group" {
  count = length(var.fivetuple_stateful_rule_group) > 0 ? length(var.fivetuple_stateful_rule_group) : 0
  type  = "STATEFUL"

  name        = var.fivetuple_stateful_rule_group[count.index]["name"]
  description = var.fivetuple_stateful_rule_group[count.index]["description"]
  capacity    = var.fivetuple_stateful_rule_group[count.index]["capacity"]

  rule_group {
    rules_source {
      dynamic "stateful_rule" {
        for_each = var.fivetuple_stateful_rule_group[count.index].rule_config
        content {
          action = upper(stateful_rule.value.actions["type"])
          header {
            destination      = stateful_rule.value.destination_ipaddress
            destination_port = stateful_rule.value.destination_port
            direction        = upper(stateful_rule.value.direction)
            protocol         = upper(stateful_rule.value.protocol)
            source           = stateful_rule.value.source_ipaddress
            source_port      = stateful_rule.value.source_port
          }
          rule_option {
            keyword  = "sid"
            settings = ["${stateful_rule.value.sid}; msg:\"${try(stateful_rule.value.description, "")}\""]
          }
        }
      }
    }
  }

  tags = merge(var.default_tags)
}

resource "aws_networkfirewall_rule_group" "stateless_group" {
  count = length(var.stateless_rule_group) > 0 ? length(var.stateless_rule_group) : 0
  type  = "STATELESS"

  name        = var.stateless_rule_group[count.index]["name"]
  description = var.stateless_rule_group[count.index]["description"]
  capacity    = var.stateless_rule_group[count.index]["capacity"]

  rule_group {
    rules_source {
      stateless_rules_and_custom_actions {
        dynamic "stateless_rule" {
          for_each = var.stateless_rule_group[count.index].rule_config
          content {
            priority = stateless_rule.value.priority
            rule_definition {
              actions = ["aws:${stateless_rule.value.actions["type"]}"]
              match_attributes {
                source {
                  address_definition = stateless_rule.value.source_ipaddress
                }
                # If protocol is TCP : 6 or UDP :17 get source ports from variables and set in source_port block
                dynamic "source_port" {
                  for_each = contains(stateless_rule.value.protocols_number, 6) || contains(stateless_rule.value.protocols_number, 17) ? try(toset([{
                    from = stateless_rule.value.source_from_port,
                    to   = stateless_rule.value.source_to_port
                  }]), []) : []
                  content {
                    from_port = source_port.value.from
                    to_port   = source_port.value.to
                  }
                }
                destination {
                  address_definition = stateless_rule.value.destination_ipaddress
                }
                # If protocol is TCP : 6 or UDP :17 get destination ports from variables and set in destination_port block
                dynamic "destination_port" {
                  for_each = contains(stateless_rule.value.protocols_number, 6) || contains(stateless_rule.value.protocols_number, 17) ? try(toset([{
                    from = stateless_rule.value.destination_from_port,
                    to   = stateless_rule.value.destination_to_port
                  }]), []) : []
                  content {
                    from_port = destination_port.value.from
                    to_port   = destination_port.value.to
                  }
                }
                protocols = stateless_rule.value.protocols_number
                dynamic "tcp_flag" {
                  for_each = contains(stateless_rule.value.protocols_number, 6) || contains(stateless_rule.value.protocols_number, 17) ? try(toset([{
                    flag  = stateless_rule.value.tcp_flag["flags"],
                    masks = stateless_rule.value.tcp_flag["masks"]
                  }]), []) : []
                  content {
                    flags = tcp_flag.value.flag
                    masks = tcp_flag.value.masks
                  }
                }
              }
            }
          }
        }
      }
    }
  }

  tags = merge(var.default_tags)
}
