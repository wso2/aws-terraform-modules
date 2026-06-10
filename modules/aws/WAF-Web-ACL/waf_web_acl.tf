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
      dynamic "action" {
        for_each = rule.value.action != null ? [rule.value.action] : []

        content {
          dynamic "allow" {
            for_each = action.value.type == "allow" ? [1] : []
            content {
              dynamic "custom_request_handling" {
                for_each = action.value.insert_header != null ? [1] : []
                content {
                  insert_header {
                    name  = action.value.insert_header.name
                    value = action.value.insert_header.value
                  }
                }
              }
            }
          }
          dynamic "block" {
            for_each = action.value.type == "block" ? [1] : []
            content {
              dynamic "custom_response" {
                for_each = action.value.response_header != null ? [1] : []
                content {
                  custom_response_body_key = action.value.custom_response_body_key
                  response_code            = action.value.response_code
                  response_header {
                    name  = action.value.response_header.name
                    value = action.value.response_header.value
                  }
                }
              }
            }
          }
        }
      }

      dynamic "override_action" {
        for_each = rule.value.override_action != null ? [rule.value.override_action] : []
        content {
          dynamic "count" {
            for_each = override_action.value.type == "count" ? [1] : []
            content {}
          }
          dynamic "none" {
            for_each = override_action.value.type == "none" ? [1] : []
            content {}
          }
        }
      }

      statement {
        dynamic "not_statement" {
          for_each = rule.value.allowed_ip_set_arn != null ? [1] : []
          content {
            statement {
              ip_set_reference_statement {
                arn = rule.value.allowed_ip_set_arn
              }
            }
          }
        }
        dynamic "ip_set_reference_statement" {
          for_each = rule.value.blocked_ip_set_arn != null ? [1] : []
          content {
            arn = rule.value.blocked_ip_set_arn
          }
        }
        dynamic "byte_match_statement" {
          for_each = rule.value.host_header != null ? [1] : []
          content {
            search_string = rule.value.host_header
            field_to_match {
              single_header {
                name = "host"
              }
            }
            text_transformation {
              priority = 0
              type     = "LOWERCASE"
            }
            positional_constraint = "EXACTLY"
          }
        }

        dynamic "managed_rule_group_statement" {
          for_each = rule.value.managed_rule_group_statement != null ? [rule.value.managed_rule_group_statement] : []
          content {
            name        = managed_rule_group_statement.value.name
            vendor_name = managed_rule_group_statement.value.vendor_name

            dynamic "rule_action_override" {
              for_each = managed_rule_group_statement.value.rule_action_overrides != null ? managed_rule_group_statement.value.rule_action_overrides : []
              content {
                name = rule_action_override.value.name
                action_to_use {
                  dynamic "count" {
                    for_each = rule_action_override.value.action == "count" ? [1] : []
                    content {}
                  }
                  dynamic "allow" {
                    for_each = rule_action_override.value.action == "allow" ? [1] : []
                    content {}
                  }
                  dynamic "block" {
                    for_each = rule_action_override.value.action == "block" ? [1] : []
                    content {}
                  }
                }
              }
            }

            dynamic "scope_down_statement" {
              for_each = try(managed_rule_group_statement.value.scope_down_statement, null) != null ? [managed_rule_group_statement.value.scope_down_statement] : []
              content {
                # Direct byte_match_statement at the top of scope_down_statement
                dynamic "byte_match_statement" {
                  for_each = scope_down_statement.value.byte_match_statement != null ? [scope_down_statement.value.byte_match_statement] : []
                  content {
                    search_string         = byte_match_statement.value.search_string
                    positional_constraint = byte_match_statement.value.positional_constraint
                    field_to_match {
                      dynamic "uri_path" {
                        for_each = byte_match_statement.value.field_to_match.uri_path == true ? [1] : []
                        content {}
                      }
                      dynamic "single_header" {
                        for_each = byte_match_statement.value.field_to_match.single_header != null ? [byte_match_statement.value.field_to_match.single_header] : []
                        content {
                          name = single_header.value
                        }
                      }
                    }
                    text_transformation {
                      priority = byte_match_statement.value.text_transformation.priority
                      type     = byte_match_statement.value.text_transformation.type
                    }
                  }
                }

                # Direct ip_set_reference_statement at the top of scope_down_statement
                dynamic "ip_set_reference_statement" {
                  for_each = scope_down_statement.value.ip_set_reference_statement != null ? [scope_down_statement.value.ip_set_reference_statement] : []
                  content {
                    arn = ip_set_reference_statement.value.arn
                  }
                }

                # Direct and_statement at the top of scope_down_statement
                dynamic "and_statement" {
                  for_each = scope_down_statement.value.and_statement != null ? [scope_down_statement.value.and_statement] : []
                  content {
                    dynamic "statement" {
                      for_each = and_statement.value.statements
                      content {
                        dynamic "byte_match_statement" {
                          for_each = statement.value.byte_match_statement != null ? [statement.value.byte_match_statement] : []
                          content {
                            search_string         = byte_match_statement.value.search_string
                            positional_constraint = byte_match_statement.value.positional_constraint
                            field_to_match {
                              dynamic "uri_path" {
                                for_each = byte_match_statement.value.field_to_match.uri_path == true ? [1] : []
                                content {}
                              }
                              dynamic "single_header" {
                                for_each = byte_match_statement.value.field_to_match.single_header != null ? [byte_match_statement.value.field_to_match.single_header] : []
                                content {
                                  name = single_header.value
                                }
                              }
                            }
                            text_transformation {
                              priority = byte_match_statement.value.text_transformation.priority
                              type     = byte_match_statement.value.text_transformation.type
                            }
                          }
                        }
                        dynamic "ip_set_reference_statement" {
                          for_each = statement.value.ip_set_reference_statement != null ? [statement.value.ip_set_reference_statement] : []
                          content {
                            arn = ip_set_reference_statement.value.arn
                          }
                        }
                      }
                    }
                  }
                }

                # Direct or_statement at the top of scope_down_statement
                dynamic "or_statement" {
                  for_each = scope_down_statement.value.or_statement != null ? [scope_down_statement.value.or_statement] : []
                  content {
                    dynamic "statement" {
                      for_each = or_statement.value.statements
                      content {
                        dynamic "byte_match_statement" {
                          for_each = statement.value.byte_match_statement != null ? [statement.value.byte_match_statement] : []
                          content {
                            search_string         = byte_match_statement.value.search_string
                            positional_constraint = byte_match_statement.value.positional_constraint
                            field_to_match {
                              dynamic "uri_path" {
                                for_each = byte_match_statement.value.field_to_match.uri_path == true ? [1] : []
                                content {}
                              }
                              dynamic "single_header" {
                                for_each = byte_match_statement.value.field_to_match.single_header != null ? [byte_match_statement.value.field_to_match.single_header] : []
                                content {
                                  name = single_header.value
                                }
                              }
                            }
                            text_transformation {
                              priority = byte_match_statement.value.text_transformation.priority
                              type     = byte_match_statement.value.text_transformation.type
                            }
                          }
                        }
                        dynamic "ip_set_reference_statement" {
                          for_each = statement.value.ip_set_reference_statement != null ? [statement.value.ip_set_reference_statement] : []
                          content {
                            arn = ip_set_reference_statement.value.arn
                          }
                        }
                      }
                    }
                  }
                }

                # not_statement wrapping a byte_match_statement, ip_set_reference_statement,
                # and_statement, or or_statement
                dynamic "not_statement" {
                  for_each = scope_down_statement.value.not_statement != null ? [scope_down_statement.value.not_statement] : []
                  content {
                    statement {
                      dynamic "byte_match_statement" {
                        for_each = not_statement.value.byte_match_statement != null ? [not_statement.value.byte_match_statement] : []
                        content {
                          search_string         = byte_match_statement.value.search_string
                          positional_constraint = byte_match_statement.value.positional_constraint
                          field_to_match {
                            dynamic "uri_path" {
                              for_each = byte_match_statement.value.field_to_match.uri_path == true ? [1] : []
                              content {}
                            }
                            dynamic "single_header" {
                              for_each = byte_match_statement.value.field_to_match.single_header != null ? [byte_match_statement.value.field_to_match.single_header] : []
                              content {
                                name = single_header.value
                              }
                            }
                          }
                          text_transformation {
                            priority = byte_match_statement.value.text_transformation.priority
                            type     = byte_match_statement.value.text_transformation.type
                          }
                        }
                      }
                      dynamic "ip_set_reference_statement" {
                        for_each = not_statement.value.ip_set_reference_statement != null ? [not_statement.value.ip_set_reference_statement] : []
                        content {
                          arn = ip_set_reference_statement.value.arn
                        }
                      }
                      dynamic "and_statement" {
                        for_each = not_statement.value.and_statement != null ? [not_statement.value.and_statement] : []
                        content {
                          dynamic "statement" {
                            for_each = and_statement.value.statements
                            content {
                              dynamic "byte_match_statement" {
                                for_each = statement.value.byte_match_statement != null ? [statement.value.byte_match_statement] : []
                                content {
                                  search_string         = byte_match_statement.value.search_string
                                  positional_constraint = byte_match_statement.value.positional_constraint
                                  field_to_match {
                                    dynamic "uri_path" {
                                      for_each = byte_match_statement.value.field_to_match.uri_path == true ? [1] : []
                                      content {}
                                    }
                                    dynamic "single_header" {
                                      for_each = byte_match_statement.value.field_to_match.single_header != null ? [byte_match_statement.value.field_to_match.single_header] : []
                                      content {
                                        name = single_header.value
                                      }
                                    }
                                  }
                                  text_transformation {
                                    priority = byte_match_statement.value.text_transformation.priority
                                    type     = byte_match_statement.value.text_transformation.type
                                  }
                                }
                              }
                              dynamic "ip_set_reference_statement" {
                                for_each = statement.value.ip_set_reference_statement != null ? [statement.value.ip_set_reference_statement] : []
                                content {
                                  arn = ip_set_reference_statement.value.arn
                                }
                              }
                            }
                          }
                        }
                      }
                      dynamic "or_statement" {
                        for_each = not_statement.value.or_statement != null ? [not_statement.value.or_statement] : []
                        content {
                          dynamic "statement" {
                            for_each = or_statement.value.statements
                            content {
                              dynamic "byte_match_statement" {
                                for_each = statement.value.byte_match_statement != null ? [statement.value.byte_match_statement] : []
                                content {
                                  search_string         = byte_match_statement.value.search_string
                                  positional_constraint = byte_match_statement.value.positional_constraint
                                  field_to_match {
                                    dynamic "uri_path" {
                                      for_each = byte_match_statement.value.field_to_match.uri_path == true ? [1] : []
                                      content {}
                                    }
                                    dynamic "single_header" {
                                      for_each = byte_match_statement.value.field_to_match.single_header != null ? [byte_match_statement.value.field_to_match.single_header] : []
                                      content {
                                        name = single_header.value
                                      }
                                    }
                                  }
                                  text_transformation {
                                    priority = byte_match_statement.value.text_transformation.priority
                                    type     = byte_match_statement.value.text_transformation.type
                                  }
                                }
                              }
                              dynamic "ip_set_reference_statement" {
                                for_each = statement.value.ip_set_reference_statement != null ? [statement.value.ip_set_reference_statement] : []
                                content {
                                  arn = ip_set_reference_statement.value.arn
                                }
                              }
                            }
                          }
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }

        dynamic "rate_based_statement" {
          for_each = rule.value.rate_based_statement != null ? [rule.value.rate_based_statement] : []
          content {
            limit              = rate_based_statement.value.limit
            aggregate_key_type = rate_based_statement.value.aggregate_key_type
          }
        }
        dynamic "and_statement" {
          for_each = rule.value.and_statement != null ? [rule.value.and_statement] : []
          content {
            dynamic "statement" {
              for_each = and_statement.value.statements
              content {

                # 1. Handle direct byte_match_statement
                dynamic "byte_match_statement" {
                  for_each = statement.value.byte_match_statement != null ? [statement.value.byte_match_statement] : []
                  content {
                    search_string         = byte_match_statement.value.search_string
                    positional_constraint = byte_match_statement.value.positional_constraint
                    field_to_match {
                      dynamic "uri_path" {
                        for_each = byte_match_statement.value.field_to_match.uri_path == true ? [1] : []
                        content {}
                      }
                      dynamic "single_header" {
                        for_each = byte_match_statement.value.field_to_match.single_header != null ? [byte_match_statement.value.field_to_match.single_header] : []
                        content {
                          name = single_header.value
                        }
                      }
                    }
                    text_transformation {
                      priority = byte_match_statement.value.text_transformation.priority
                      type     = byte_match_statement.value.text_transformation.type
                    }
                  }
                }

                # 2. Handle nested not_statement
                dynamic "not_statement" {
                  for_each = statement.value.not_statement != null ? [statement.value.not_statement] : []
                  content {
                    statement {
                      dynamic "byte_match_statement" {
                        for_each = not_statement.value.byte_match_statement != null ? [not_statement.value.byte_match_statement] : []
                        content {
                          search_string         = byte_match_statement.value.search_string
                          positional_constraint = byte_match_statement.value.positional_constraint
                          field_to_match {
                            dynamic "uri_path" {
                              for_each = byte_match_statement.value.field_to_match.uri_path == true ? [1] : []
                              content {}
                            }
                            dynamic "single_header" {
                              for_each = byte_match_statement.value.field_to_match.single_header != null ? [byte_match_statement.value.field_to_match.single_header] : []
                              content {
                                name = single_header.value
                              }
                            }
                          }
                          text_transformation {
                            priority = byte_match_statement.value.text_transformation.priority
                            type     = byte_match_statement.value.text_transformation.type
                          }
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }

        # labeled_host_scoped_block_statement: renders
        #   AND(label_match_statement, NOT(byte_match host ENDS_WITH suffix))
        # so the rule's action only fires on requests carrying the label AND
        # whose host header does NOT match the suffix. Pairs with a managed
        # rule group whose sub-rule is overridden to `count` so the label is
        # emitted but the managed group itself does not block.
        dynamic "and_statement" {
          for_each = rule.value.labeled_host_scoped_block_statement != null ? [rule.value.labeled_host_scoped_block_statement] : []
          content {
            statement {
              label_match_statement {
                scope = "LABEL"
                key   = and_statement.value.label_name
              }
            }
            statement {
              not_statement {
                statement {
                  byte_match_statement {
                    search_string         = and_statement.value.host_header_suffix
                    positional_constraint = "ENDS_WITH"
                    field_to_match {
                      single_header {
                        name = "host"
                      }
                    }
                    text_transformation {
                      priority = 0
                      type     = "LOWERCASE"
                    }
                  }
                }
              }
            }
          }
        }
      }

      visibility_config {
        cloudwatch_metrics_enabled = rule.value.cloudwatch_metrics_enabled
        metric_name                = rule.value.cloudwatch_metric_name
        sampled_requests_enabled   = rule.value.sampled_requests_enabled
      }
    }
  }
}
