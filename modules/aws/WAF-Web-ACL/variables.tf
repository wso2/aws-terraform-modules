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

variable "name" {
  description = "Name of the WAF ACL"
  type        = string
}

variable "scope" {
  description = "The scope of the WAF ACL. Valid values are REGIONAL or CLOUDFRONT"
  type        = string
}

variable "description" {
  description = "The description of the WAF ACL"
  type        = string
}

variable "cloudwatch_metrics_enabled" {
  description = "Whether the associated resource sends metrics to CloudWatch"
  type        = bool
  default     = true
}

variable "cloudwatch_metric_name" {
  description = "The name of the CloudWatch metric"
  type        = string
  default     = "WAFACL"
}

variable "sampled_requests_enabled" {
  description = "Whether AWS WAF should store a sampling of the web requests that match the rules"
  type        = string
}

variable "default_action" {
  description = "The action that you want AWS WAF to take when a request doesn't match the criteria specified in any of the rules that are associated with the web ACL"
  type = object({
    type = string
    insert_header = optional(object({
      name  = string
      value = string
    }))
    custom_response_body_key = optional(string)
    response_code            = optional(number)
    response_header = optional(object({
      name  = string
      value = string
    }))
  })
}

variable "custom_response_body" {
  description = "The custom response to send (for example, custom page) when a request is blocked"
  type = map(object({
    content_type = string
    content      = string
    key          = string
  }))
  default = {}
}

variable "rules" {
  description = "The rules to associate with the web ACL"
  type = map(object({
    name                       = string
    priority                   = number
    cloudwatch_metrics_enabled = bool
    cloudwatch_metric_name     = string
    sampled_requests_enabled   = bool

    action = optional(object({
      type = string
      insert_header = optional(object({
        name  = string
        value = string
      }))
      custom_response_body_key = optional(string)
      response_code            = optional(number)
      response_header = optional(object({
        name  = string
        value = string
      }))
    }))

    override_action = optional(object({
      type = string
    }))
    allowed_ip_set_arn = optional(string)
    blocked_ip_set_arn = optional(string)
    host_header        = optional(string)
    managed_rule_group_statement = optional(object({
      name        = string
      vendor_name = string
      rule_action_overrides = optional(list(object({
        name   = string
        action = string # count, allow, block
      })), [])
      # Optional scope-down: restrict the managed rule group to a subset of requests.
      # Supports byte_match_statement, ip_set_reference_statement, and_statement, or_statement,
      # and not_statement (wrapping any of the above) at the top level. Inside and_statement /
      # or_statement statements, each entry must be exactly one of byte_match_statement OR
      # ip_set_reference_statement. Use not_statement+ip_set_reference to SKIP a managed rule
      # group for trusted source IPs (e.g. internal NAT egress); use not_statement+or with
      # mixed byte_match + ip_set_reference entries to combine path-based and IP-based skips.
      scope_down_statement = optional(object({
        byte_match_statement = optional(object({
          search_string         = string
          positional_constraint = string
          field_to_match = object({
            uri_path      = optional(bool)
            single_header = optional(string)
          })
          text_transformation = object({
            priority = number
            type     = string
          })
        }))
        ip_set_reference_statement = optional(object({
          arn = string
        }))
        and_statement = optional(object({
          statements = list(object({
            byte_match_statement = optional(object({
              search_string         = string
              positional_constraint = string
              field_to_match = object({
                uri_path      = optional(bool)
                single_header = optional(string)
              })
              text_transformation = object({
                priority = number
                type     = string
              })
            }))
            ip_set_reference_statement = optional(object({
              arn = string
            }))
          }))
        }))
        or_statement = optional(object({
          statements = list(object({
            byte_match_statement = optional(object({
              search_string         = string
              positional_constraint = string
              field_to_match = object({
                uri_path      = optional(bool)
                single_header = optional(string)
              })
              text_transformation = object({
                priority = number
                type     = string
              })
            }))
            ip_set_reference_statement = optional(object({
              arn = string
            }))
          }))
        }))
        not_statement = optional(object({
          byte_match_statement = optional(object({
            search_string         = string
            positional_constraint = string
            field_to_match = object({
              uri_path      = optional(bool)
              single_header = optional(string)
            })
            text_transformation = object({
              priority = number
              type     = string
            })
          }))
          ip_set_reference_statement = optional(object({
            arn = string
          }))
          and_statement = optional(object({
            statements = list(object({
              byte_match_statement = optional(object({
                search_string         = string
                positional_constraint = string
                field_to_match = object({
                  uri_path      = optional(bool)
                  single_header = optional(string)
                })
                text_transformation = object({
                  priority = number
                  type     = string
                })
              }))
              ip_set_reference_statement = optional(object({
                arn = string
              }))
            }))
          }))
          or_statement = optional(object({
            statements = list(object({
              byte_match_statement = optional(object({
                search_string         = string
                positional_constraint = string
                field_to_match = object({
                  uri_path      = optional(bool)
                  single_header = optional(string)
                })
                text_transformation = object({
                  priority = number
                  type     = string
                })
              }))
              ip_set_reference_statement = optional(object({
                arn = string
              }))
            }))
          }))
        }))
      }))
    }))
    rate_based_statement = optional(object({
      limit              = number
      aggregate_key_type = string
    }))

    and_statement = optional(object({
      statements = list(object({
        byte_match_statement = optional(object({
          search_string         = string
          positional_constraint = string
          field_to_match = object({
            uri_path      = optional(bool)
            single_header = optional(string)
          })
          text_transformation = object({
            priority = number
            type     = string
          })
        }))
        not_statement = optional(object({
          byte_match_statement = optional(object({
            search_string         = string
            positional_constraint = string
            field_to_match = object({
              uri_path      = optional(bool)
              single_header = optional(string)
            })
            text_transformation = object({
              priority = number
              type     = string
            })
          }))
        }))
      }))
    }))

    # Narrow purpose-built rule: blocks requests that carry a specific label
    # (e.g. a managed-rule-group sub-rule label set to count via
    # rule_action_overrides) UNLESS the host header ends with the given
    # suffix. Renders as AND(label_match_statement, NOT(byte_match host
    # ENDS_WITH suffix)). Useful for host-scoping a managed sub-rule action
    # without disabling the whole rule group.
    labeled_host_scoped_block_statement = optional(object({
      label_name         = string
      host_header_suffix = string
    }))

    # Narrow purpose-built rule: fires on requests whose host header equals
    # host_header AND whose source IP is NOT in the referenced IP set.
    # Renders as AND(byte_match host EXACTLY host_header, NOT(ip_set_reference
    # allowed_ip_set_arn)). Pair with action = block to restrict a specific
    # host to an IP allowlist without changing the WAF's global filter mode.
    host_scoped_ip_allowlist_block_statement = optional(object({
      host_header        = string
      allowed_ip_set_arn = string
    }))

    # Narrow purpose-built rule: fires on requests whose host header equals
    # host_header AND whose URI path starts with uri_path_prefix AND (for
    # each entry in excluded_uri_path_prefixes) does NOT start with that
    # excluded prefix AND whose source IP is NOT in the referenced IP set.
    # Renders as
    #   AND(byte_match host EXACTLY host_header,
    #       byte_match uri STARTS_WITH uri_path_prefix,
    #       NOT(byte_match uri STARTS_WITH excluded_uri_path_prefixes[0]),
    #       NOT(byte_match uri STARTS_WITH excluded_uri_path_prefixes[1]),
    #       ...
    #       NOT(ip_set_reference allowed_ip_set_arn))
    # Pair with action = block to restrict a specific host+path prefix to an
    # IP allowlist (e.g. lock a single API endpoint to an internal NAT egress
    # range) without affecting other paths on the same host or changing the
    # WAF's global filter mode. Use excluded_uri_path_prefixes to carve
    # sub-paths back out of the restriction (e.g. leave admin endpoints
    # reachable from the front-door allowlist while the rest of the endpoint
    # is locked to internal NAT). host_header, uri_path_prefix, and every
    # entry in excluded_uri_path_prefixes are matched against a LOWERCASE-
    # transformed field and WAF does not transform the search_string, so all
    # must be provided lowercase; uri_path_prefix and each excluded prefix
    # must begin with '/'.
    host_and_path_scoped_ip_allowlist_block_statement = optional(object({
      host_header                = string
      uri_path_prefix            = string
      allowed_ip_set_arn         = string
      excluded_uri_path_prefixes = optional(list(string), [])
    }))

    # Matches requests whose source IP geolocates to one of the given
    # ISO 3166-1 alpha-2 country codes. Pair with action = block to deny
    # traffic originating from specific countries (e.g. sanctioned
    # jurisdictions). Geolocation is resolved by AWS WAF from the request's
    # source IP; sub-national regions (e.g. Crimea) cannot be targeted by
    # country code.
    geo_match_statement = optional(object({
      country_codes = list(string)
    }))
  }))

  # Validation 0: geo_match_statement.country_codes must be non-empty and each
  # entry a two-letter uppercase ISO 3166-1 alpha-2 code (AWS WAF rejects
  # anything else at apply time; catch it at plan time instead).
  validation {
    condition = alltrue([
      for v in var.rules :
      length(v.geo_match_statement.country_codes) > 0 && alltrue([
        for c in v.geo_match_statement.country_codes :
        can(regex("^[A-Z]{2}$", c))
      ])
      if try(v.geo_match_statement, null) != null
    ])
    error_message = "geo_match_statement.country_codes must be a non-empty list of two-letter uppercase ISO 3166-1 alpha-2 country codes (e.g. \"IR\", \"KP\")."
  }

  # Validation 1: AWS WAF requires an and_statement to have >= 2 nested statements
  validation {
    condition = alltrue([
      for v in var.rules :
      length(v.and_statement.statements) >= 2
      if try(v.and_statement, null) != null
    ])
    error_message = "AWS WAF requires an and_statement to contain at least 2 statements."
  }

  # Validation 2: Ensure exactly one statement type is used per statement
  validation {
    condition = alltrue(flatten([
      for v in var.rules : [
        for s in v.and_statement.statements :
        (try(s.byte_match_statement, null) != null ? 1 : 0) + (try(s.not_statement, null) != null ? 1 : 0) == 1
      ]
      if try(v.and_statement, null) != null
    ]))
    error_message = "Each nested statement within an and_statement must specify exactly one statement type (byte_match_statement XOR not_statement)."
  }

  # Validation 3: Ensure exactly one field_to_match selector is set inside byte_match_statements
  validation {
    condition = alltrue(flatten([
      for v in var.rules : [
        for s in v.and_statement.statements : [
          for bm in [try(s.byte_match_statement, null), try(s.not_statement.byte_match_statement, null)] :
          (try(bm.field_to_match.uri_path, false) == true ? 1 : 0) + (try(bm.field_to_match.single_header, null) != null ? 1 : 0) == 1
          if bm != null
        ]
      ]
      if try(v.and_statement, null) != null
    ]))
    error_message = "Inside byte_match_statement.field_to_match, exactly one field selector (uri_path or single_header) must be set."
  }

  # Validation 4: Ensure managed rule action overrides use supported actions
  validation {
    condition = alltrue(flatten([
      for v in var.rules : [
        for o in try(v.managed_rule_group_statement.rule_action_overrides, []) :
        contains(["count", "allow", "block"], lower(trimspace(o.action)))
      ]
    ]))
    error_message = "managed_rule_group_statement.rule_action_overrides[*].action must be one of: count, allow, block."
  }

  # Validation 5: managed_rule_group_statement.scope_down_statement must specify exactly one of
  # byte_match_statement, ip_set_reference_statement, and_statement, or_statement, or not_statement.
  validation {
    condition = alltrue([
      for v in var.rules :
      (try(v.managed_rule_group_statement.scope_down_statement.byte_match_statement, null) != null ? 1 : 0) +
      (try(v.managed_rule_group_statement.scope_down_statement.ip_set_reference_statement, null) != null ? 1 : 0) +
      (try(v.managed_rule_group_statement.scope_down_statement.and_statement, null) != null ? 1 : 0) +
      (try(v.managed_rule_group_statement.scope_down_statement.or_statement, null) != null ? 1 : 0) +
      (try(v.managed_rule_group_statement.scope_down_statement.not_statement, null) != null ? 1 : 0) == 1
      if try(v.managed_rule_group_statement.scope_down_statement, null) != null
    ])
    error_message = "managed_rule_group_statement.scope_down_statement must specify exactly one of byte_match_statement, ip_set_reference_statement, and_statement, or_statement, or not_statement."
  }
  # Validation 6: When scope_down_statement.not_statement is used, exactly one of
  # byte_match_statement, ip_set_reference_statement, and_statement, or or_statement must be set under it.
  validation {
    condition = alltrue([
      for v in var.rules :
      (try(v.managed_rule_group_statement.scope_down_statement.not_statement.byte_match_statement, null) != null ? 1 : 0) +
      (try(v.managed_rule_group_statement.scope_down_statement.not_statement.ip_set_reference_statement, null) != null ? 1 : 0) +
      (try(v.managed_rule_group_statement.scope_down_statement.not_statement.and_statement, null) != null ? 1 : 0) +
      (try(v.managed_rule_group_statement.scope_down_statement.not_statement.or_statement, null) != null ? 1 : 0) == 1
      if try(v.managed_rule_group_statement.scope_down_statement.not_statement, null) != null
    ])
    error_message = "managed_rule_group_statement.scope_down_statement.not_statement must contain exactly one of byte_match_statement, ip_set_reference_statement, and_statement, or or_statement."
  }

  # Validation 7: and_statement / or_statement inside scope_down_statement (directly or under
  # not_statement) must each contain >= 2 statements.
  validation {
    condition = alltrue(flatten([
      for v in var.rules : [
        for stmts in [
          try(v.managed_rule_group_statement.scope_down_statement.and_statement.statements, null),
          try(v.managed_rule_group_statement.scope_down_statement.or_statement.statements, null),
          try(v.managed_rule_group_statement.scope_down_statement.not_statement.and_statement.statements, null),
          try(v.managed_rule_group_statement.scope_down_statement.not_statement.or_statement.statements, null),
        ] :
        length(stmts) >= 2
        if stmts != null
      ]
    ]))
    error_message = "and_statement / or_statement inside scope_down_statement must contain at least 2 statements."
  }

  # Validation: host_and_path_scoped_ip_allowlist_block_statement.host_header,
  # uri_path_prefix, and every entry in excluded_uri_path_prefixes must be
  # lowercase; the request field is matched with a LOWERCASE text_transformation
  # but WAF does not transform the search_string, so a mixed-case search
  # string would never match. uri_path_prefix and each excluded prefix must
  # also begin with '/'.
  validation {
    condition = alltrue([
      for v in var.rules :
      (
        v.host_and_path_scoped_ip_allowlist_block_statement.host_header == lower(v.host_and_path_scoped_ip_allowlist_block_statement.host_header)
        && v.host_and_path_scoped_ip_allowlist_block_statement.uri_path_prefix == lower(v.host_and_path_scoped_ip_allowlist_block_statement.uri_path_prefix)
        && startswith(v.host_and_path_scoped_ip_allowlist_block_statement.uri_path_prefix, "/")
        && alltrue([
          for p in coalesce(v.host_and_path_scoped_ip_allowlist_block_statement.excluded_uri_path_prefixes, []) :
          p == lower(p) && startswith(p, "/")
        ])
      )
      if try(v.host_and_path_scoped_ip_allowlist_block_statement, null) != null
    ])
    error_message = "host_and_path_scoped_ip_allowlist_block_statement.host_header, uri_path_prefix, and every entry in excluded_uri_path_prefixes must be lowercase, and uri_path_prefix + each excluded prefix must begin with '/' (WAF applies LOWERCASE to the request field but does not transform the search_string; uri_path always begins with '/')."
  }

  # Validation 8: each entry in scope_down_statement.and_statement.statements,
  # scope_down_statement.or_statement.statements, and the same lists under not_statement,
  # must specify exactly one of byte_match_statement or ip_set_reference_statement.
  validation {
    condition = alltrue(flatten([
      for v in var.rules : [
        for stmts in [
          try(v.managed_rule_group_statement.scope_down_statement.and_statement.statements, null),
          try(v.managed_rule_group_statement.scope_down_statement.or_statement.statements, null),
          try(v.managed_rule_group_statement.scope_down_statement.not_statement.and_statement.statements, null),
          try(v.managed_rule_group_statement.scope_down_statement.not_statement.or_statement.statements, null),
          ] : [
          for s in(stmts != null ? stmts : []) :
          (try(s.byte_match_statement, null) != null ? 1 : 0) +
          (try(s.ip_set_reference_statement, null) != null ? 1 : 0) == 1
        ]
      ]
    ]))
    error_message = "Each statement inside scope_down_statement.and_statement.statements / or_statement.statements (and their not_statement-nested variants) must specify exactly one of byte_match_statement or ip_set_reference_statement."
  }
}

variable "tags" {
  description = "A map of tags to assign to the resource"
  type        = map(string)
  default     = {}
}

# ---------------------------------------------------------------------------
# WAF Logging
# ---------------------------------------------------------------------------

variable "enable_logging" {
  description = "When true, enables WAF logging to the specified log_destination_arns. The log destination (e.g. CloudWatch log group) must have a name starting with 'aws-waf-logs-'."
  type        = bool
  default     = false
}

variable "log_destination_arns" {
  description = "List of ARNs for the WAF log destinations (CloudWatch log group, S3 bucket, or Kinesis Firehose). Required when enable_logging is true. CloudWatch log group names must start with 'aws-waf-logs-'."
  type        = list(string)
  default     = []
}

variable "log_filter_default_behavior" {
  description = "Default logging filter behaviour for requests that do not match any filter. DROP reduces log volume by discarding normal ALLOW traffic. Valid values: KEEP, DROP."
  type        = string
  default     = "DROP"

  validation {
    condition     = contains(["KEEP", "DROP"], var.log_filter_default_behavior)
    error_message = "log_filter_default_behavior must be KEEP or DROP."
  }
}

variable "log_filter_keep_actions" {
  description = "List of WAF final actions whose matching requests are kept (logged). EXCLUDED_AS_COUNT captures managed rule group matches in count-override mode. Valid values: ALLOW, BLOCK, COUNT, CAPTCHA, CHALLENGE, EXCLUDED_AS_COUNT."
  type        = list(string)
  default     = ["BLOCK", "EXCLUDED_AS_COUNT"]

  validation {
    condition = alltrue([
      for a in var.log_filter_keep_actions :
      contains(["ALLOW", "BLOCK", "COUNT", "CAPTCHA", "CHALLENGE", "EXCLUDED_AS_COUNT"], a)
    ])
    error_message = "Each entry in log_filter_keep_actions must be one of: ALLOW, BLOCK, COUNT, CAPTCHA, CHALLENGE, EXCLUDED_AS_COUNT."
  }
}
