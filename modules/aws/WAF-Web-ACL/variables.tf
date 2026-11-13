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
    # Rate-based rule: tracks the request rate per aggregation key over a
    # 5-minute rolling window and applies the rule action to keys whose rate
    # exceeds limit. Optional scope-down restricts which requests count
    # toward (and are affected by) the limit — supports ip_set_reference
    # directly, not_statement wrapping one (use to exempt trusted source IPs,
    # e.g. internal NAT egress, from rate limiting), or the purpose-built
    # uri_path_scoped_statement below to rate-limit a specific URI path
    # prefix (optionally on a single host) independently of the rest of the
    # traffic behind the Web ACL.
    rate_based_statement = optional(object({
      limit              = number
      aggregate_key_type = string
      scope_down_statement = optional(object({
        ip_set_reference_statement = optional(object({
          arn = string
        }))
        not_statement = optional(object({
          ip_set_reference_statement = optional(object({
            arn = string
          }))
        }))
        # Narrow purpose-built scope-down for URI-scoped rate limits: only
        # requests whose URI path STARTS_WITH uri_path_prefix count toward
        # (and are affected by) the limit. host_header additionally requires
        # an EXACTLY host match, each excluded_uri_path_prefixes entry carves
        # a sub-path back out of the scope, and exempt_ip_set_arn exempts
        # source IPs in the referenced IP set (e.g. trusted NAT egress).
        # Renders as
        #   AND(byte_match uri STARTS_WITH uri_path_prefix,
        #       [byte_match host EXACTLY host_header,]
        #       [NOT(byte_match uri STARTS_WITH excluded_uri_path_prefixes[i]), ...]
        #       [NOT(ip_set_reference exempt_ip_set_arn)])
        # or as the bare uri byte_match when no optional field is set (AWS
        # WAF rejects an and_statement with fewer than 2 nested statements).
        uri_path_scoped_statement = optional(object({
          uri_path_prefix            = string
          host_header                = optional(string)
          excluded_uri_path_prefixes = optional(list(string), [])
          exempt_ip_set_arn          = optional(string)
        }))
      }))
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
    # rule_action_overrides) UNLESS the host header ends with one of the
    # given suffixes. Renders as
    #   AND(label_match_statement,
    #       NOT(byte_match host ENDS_WITH suffixes[0]),
    #       NOT(byte_match host ENDS_WITH suffixes[1]),
    #       ...)
    # i.e. NOT(OR(...)) expanded by De Morgan so the nesting depth stays the
    # same as the single-suffix form. Useful for host-scoping a managed
    # sub-rule action without disabling the whole rule group.
    #
    # Set exactly one of host_header_suffix (single suffix) or
    # host_header_suffixes (several hosts exempt from the SAME label). Use one
    # rule with host_header_suffixes rather than one rule per host: separate
    # rules on the same label each re-block every host outside their own
    # suffix, so the exempt set becomes the intersection of the suffixes
    # (usually empty) instead of their union. A single host_header_suffix
    # renders exactly as before this field existed, so existing callers see
    # no plan diff. Suffixes are matched against a LOWERCASE-transformed Host
    # header and WAF does not transform the search_string, so all must be
    # lowercase.
    labeled_host_scoped_block_statement = optional(object({
      label_name           = string
      host_header_suffix   = optional(string)
      host_header_suffixes = optional(list(string), [])
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
    # host_header AND whose source IP is NOT in the referenced IP set (when one
    # is given) AND whose Authorization header matches NONE of
    # authorization_values. Renders as
    #   AND(byte_match host EXACTLY host_header,
    #       NOT(ip_set_reference allowed_ip_set_arn),
    #       NOT(byte_match authorization EXACTLY authorization_values[0]),
    #       NOT(byte_match authorization EXACTLY authorization_values[1]),
    #       ...)
    # Each credential is emitted as its own NOT-wrapped AND-sibling rather than
    # NOT(OR(...)) so the shape holds uniformly for 1 or N credentials without
    # tripping AWS WAF's >=2-statements-per-OR requirement.
    #
    # Pair with action = block carrying response_code 401 and a
    # WWW-Authenticate response_header to put an HTTP basic-auth prompt in
    # front of a single host: source IPs in the allowlist are served without a
    # prompt, everyone else is challenged and admitted only by presenting one
    # of the issued credentials. authorization_values carry the full header
    # value ("Basic " + base64("user:password")) and are matched with text
    # transformation NONE, since base64 is case-sensitive.
    #
    # The credentials are readable to anyone who can read the Web ACL, and the
    # browser keeps sending them for the life of the tab. This gates a
    # pre-release host; it is not an authentication system.
    host_scoped_basic_auth_block_statement = optional(object({
      host_header          = string
      allowed_ip_set_arn   = optional(string)
      authorization_values = list(string)
    }))

    # Narrow purpose-built rule: fires on requests whose host header equals
    # host_header AND whose Authorization header matches ANY of
    # authorization_values. Renders as
    #   AND(byte_match host EXACTLY host_header,
    #       byte_match authorization EXACTLY authorization_values[0])
    # for a single credential, and as
    #   AND(byte_match host EXACTLY host_header,
    #       OR(byte_match authorization EXACTLY authorization_values[0],
    #          byte_match authorization EXACTLY authorization_values[1], ...))
    # for two or more — the single-credential form stays a bare sibling
    # because AWS WAF requires at least 2 statements inside an OR.
    #
    # This is the admit half of the basic-auth pair: pair it with
    # action = allow, at a priority ahead of an IP-filter block rule, so a
    # visitor who answers the challenge from
    # host_scoped_basic_auth_block_statement is not then denied by the IP
    # filter. The two statements are disjoint by construction (one requires a
    # known credential, the other requires none to match), so their relative
    # priority does not matter.
    #
    # NOTE: an allow action terminates Web ACL evaluation, so requests admitted
    # by this rule skip every later rule — managed rule groups included. Keep
    # its priority as late as the IP-filter rule allows, and treat the host as
    # one whose traffic is gated but not inspected.
    host_scoped_authorization_allow_statement = optional(object({
      host_header          = string
      authorization_values = list(string)
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

    # Narrow purpose-built rule: fires on requests whose host header equals
    # host_header AND whose URI path starts with uri_path_prefix AND (for
    # each entry in excluded_uri_path_prefixes) does NOT start with that
    # excluded prefix. Renders as
    #   AND(byte_match host EXACTLY host_header,
    #       byte_match uri STARTS_WITH uri_path_prefix,
    #       NOT(byte_match uri STARTS_WITH excluded_uri_path_prefixes[0]),
    #       ...)
    # Pair with action = allow to exempt a single endpoint on an otherwise
    # IP-restricted host from later-priority filter rules (e.g. open a JWKS
    # endpoint to the public internet while the rest of the host stays behind
    # an IP allowlist), or with action = block/count for host+path-scoped
    # deny/observe rules that need no IP-set condition. host_header,
    # uri_path_prefix, and every entry in excluded_uri_path_prefixes are
    # matched against a LOWERCASE-transformed field and WAF does not transform
    # the search_string, so all must be provided lowercase; uri_path_prefix
    # and each excluded prefix must begin with '/'.
    host_and_path_scoped_statement = optional(object({
      host_header                = string
      uri_path_prefix            = string
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

    # Matches requests carrying a WAF label added by an earlier-priority rule
    # (labels only exist on a request after the rule that emits them has been
    # evaluated). Example: pair a count-action geo_match_statement rule (which
    # makes WAF emit awswaf:clientip:geo:region:<ISO-3166-2> labels) with a
    # block-action label_match_statement rule on a specific region label to
    # block sub-national regions that geo_match_statement alone cannot target.
    # scope LABEL matches one label key exactly; NAMESPACE matches a label
    # prefix.
    label_match_statement = optional(object({
      scope = optional(string, "LABEL")
      key   = string
    }))

    # Narrow purpose-built rule: blocks requests that carry any of the given
    # labels (e.g. managed-rule-group sub-rule labels set to count via
    # rule_action_overrides) UNLESS the request matches EVERY exempt_*
    # condition set on the statement. The conditions, in rendering order:
    #
    #   exempt_host_header_suffix  byte_match  host ENDS_WITH, LOWERCASE
    #   exempt_uri_path_prefix     byte_match  uri_path STARTS_WITH, URL_DECODE + NORMALIZE_PATH
    #   exempt_uri_path_regex      regex_match uri_path, URL_DECODE + NORMALIZE_PATH
    #   exempt_methods             regex_match method ^(m1|m2|...)$, no transform
    #   exempt_query_string_regex  regex_match query_string, URL_DECODE + LOWERCASE
    #
    # Set exactly one of exempt_uri_path_prefix (one endpoint or subtree) and
    # exempt_uri_path_regex (several unrelated endpoints, e.g.
    # "^/oauth2/(authorize|logout)" — an OR of byte matches would exceed the
    # provider's nesting depth here). Every other condition is optional and
    # omitted conditions simply do not narrow the exemption. Renders as
    #   AND(label_match label_names[0],
    #       NOT(AND(<condition>, <condition>, ...)))
    # Two or more label_names render as OR(label_match ...), and a single
    # exempt condition renders NOT(<condition>) directly, because AWS WAF
    # requires at least 2 statements inside an AND or OR. This is the
    # request-scoped counterpart of labeled_host_scoped_block_statement: use it
    # when one endpoint, rather than a whole host, needs to be exempt from a
    # managed sub-rule while every other request keeps its blocking.
    #
    # URL_DECODE then NORMALIZE_PATH decodes percent-encoding, collapses
    # repeated slashes and resolves "./" and "../" segments, so neither
    # <prefix>/../other nor <prefix>%2F..%2Fother gets the exemption. The path match
    # is case-sensitive (no LOWERCASE transform), so a differently-cased path
    # is not exempt. The method set is one regex rather than an OR of byte
    # matches, for the same nesting-depth reason as exempt_uri_path_regex.
    #
    # exempt_query_string_regex narrows the exemption to requests whose query
    # string carries an expected pattern (e.g. a loopback redirect_uri on an
    # OAuth authorize call). It is matched after a single URL_DECODE, so a
    # double-encoded payload does not reach the exemption and stays blocked.
    # A query string can hold several parameters, so an exemption keyed on one
    # of them still lets the rest of the query string through the relaxed
    # sub-rule: pair it with a uri_path_scoped_query_string_regex_statement
    # rule to keep the dangerous pattern blocked on the exempt endpoint.
    labeled_request_scoped_block_statement = optional(object({
      label_names               = list(string)
      exempt_uri_path_prefix    = optional(string)
      exempt_uri_path_regex     = optional(string)
      exempt_methods            = optional(list(string), [])
      exempt_host_header_suffix = optional(string)
      exempt_query_string_regex = optional(string)
    }))

    # Narrow purpose-built rule: matches requests whose URI path (after
    # URL_DECODE and NORMALIZE_PATH, as above) starts with uri_path_prefix
    # AND whose body matches regex_string after text_transformations (applied
    # in list order).
    # Renders as
    #   AND(byte_match uri_path STARTS_WITH uri_path_prefix,
    #       regex_match body regex_string)
    # Pair with action = block to keep a body pattern out of one endpoint, e.g.
    # to keep blocking cloud metadata service addresses on an endpoint that a
    # labeled_request_scoped_block_statement exempts from a managed body
    # sub-rule. oversize_handling decides what happens when the body is larger
    # than the resource's body inspection limit: CONTINUE inspects the part
    # that fits, MATCH treats the request as matching, NO_MATCH as not
    # matching. The path match is case-sensitive, as above.
    uri_path_scoped_body_regex_statement = optional(object({
      uri_path_prefix      = string
      regex_string         = string
      text_transformations = optional(list(string), ["URL_DECODE", "LOWERCASE"])
      oversize_handling    = optional(string, "CONTINUE")
    }))

    # Narrow purpose-built rule: matches requests whose URI path (after
    # URL_DECODE and NORMALIZE_PATH, as above) starts with uri_path_prefix
    # AND whose query string matches regex_string after text_transformations
    # (applied in list order).
    # Renders as
    #   AND(byte_match uri_path STARTS_WITH uri_path_prefix,
    #       regex_match query_string regex_string)
    # The query-string counterpart of uri_path_scoped_body_regex_statement:
    # pair it with action = block to keep a pattern out of one endpoint's
    # query string, e.g. to keep blocking cloud metadata service addresses on
    # an endpoint that a labeled_request_scoped_block_statement exempts from a
    # managed query-argument sub-rule. AWS WAF inspects the whole query string
    # (it is part of the request line, not the body), so unlike the body
    # statement there is no oversize handling to configure. The path match is
    # case-sensitive, as above.
    uri_path_scoped_query_string_regex_statement = optional(object({
      uri_path_prefix      = string
      regex_string         = string
      text_transformations = optional(list(string), ["URL_DECODE", "LOWERCASE"])
    }))
  }))

  # Validation 0: geo_match_statement.country_codes must be non-empty and each
  # entry a two-letter uppercase ISO 3166-1 alpha-2 code (AWS WAF rejects
  # anything else at apply time; catch it at plan time instead).


  validation {
    condition = alltrue([
      for k, r in var.rules :
      r.host_scoped_authorization_allow_statement == null ||
      length(r.host_scoped_authorization_allow_statement.authorization_values) > 0
    ])
    error_message = "host_scoped_authorization_allow_statement.authorization_values must hold at least one \"Basic <base64>\" value - with none the AND would collapse to a single statement and AWS WAF requires at least two."
  }
  validation {
    condition = alltrue([
      for k, r in var.rules :
      r.host_scoped_basic_auth_block_statement == null ||
      length(r.host_scoped_basic_auth_block_statement.authorization_values) > 0
    ])
    error_message = "host_scoped_basic_auth_block_statement.authorization_values must hold at least one \"Basic <base64>\" value - a basic-auth rule with no credential blocks every request that is not already IP-allowlisted."
  }
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

  # Validation 0b: label_match_statement.scope must be LABEL or NAMESPACE, and
  # key must be non-empty.
  validation {
    condition = alltrue([
      for v in var.rules :
      contains(["LABEL", "NAMESPACE"], v.label_match_statement.scope) && length(v.label_match_statement.key) > 0
      if try(v.label_match_statement, null) != null
    ])
    error_message = "label_match_statement.scope must be LABEL or NAMESPACE and key must be non-empty."
  }

  # Validation 0c: action.type must be allow, block, or count.
  validation {
    condition = alltrue([
      for v in var.rules :
      contains(["allow", "block", "count"], v.action.type)
      if try(v.action, null) != null
    ])
    error_message = "action.type must be one of: allow, block, count."
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

  # Validation: labeled_host_scoped_block_statement must set exactly one of
  # host_header_suffix / host_header_suffixes, and every suffix must be
  # non-empty, lowercase, and unique within the rule (the Host header is
  # LOWERCASE-transformed before matching but the search_string is not).
  validation {
    condition = alltrue([
      for v in var.rules :
      (
        (v.labeled_host_scoped_block_statement.host_header_suffix != null) != (length(coalesce(v.labeled_host_scoped_block_statement.host_header_suffixes, [])) > 0)
        && alltrue([
          for s in(v.labeled_host_scoped_block_statement.host_header_suffix != null ? [v.labeled_host_scoped_block_statement.host_header_suffix] : coalesce(v.labeled_host_scoped_block_statement.host_header_suffixes, [])) :
          length(s) > 0 && s == lower(s)
        ])
        && length(distinct(coalesce(v.labeled_host_scoped_block_statement.host_header_suffixes, []))) == length(coalesce(v.labeled_host_scoped_block_statement.host_header_suffixes, []))
      )
      if try(v.labeled_host_scoped_block_statement, null) != null
    ])
    error_message = "labeled_host_scoped_block_statement must set exactly one of host_header_suffix or a non-empty host_header_suffixes, and every suffix must be non-empty, lowercase, and unique (WAF applies LOWERCASE to the Host header but does not transform the search_string)."
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

  # Validation: host_and_path_scoped_statement.host_header, uri_path_prefix,
  # and every entry in excluded_uri_path_prefixes must be lowercase; the
  # request field is matched with a LOWERCASE text_transformation but WAF does
  # not transform the search_string, so a mixed-case search string would never
  # match. uri_path_prefix and each excluded prefix must also begin with '/'.
  validation {
    condition = alltrue([
      for v in var.rules :
      (
        v.host_and_path_scoped_statement.host_header == lower(v.host_and_path_scoped_statement.host_header)
        && v.host_and_path_scoped_statement.uri_path_prefix == lower(v.host_and_path_scoped_statement.uri_path_prefix)
        && startswith(v.host_and_path_scoped_statement.uri_path_prefix, "/")
        && alltrue([
          for p in coalesce(v.host_and_path_scoped_statement.excluded_uri_path_prefixes, []) :
          p == lower(p) && startswith(p, "/")
        ])
      )
      if try(v.host_and_path_scoped_statement, null) != null
    ])
    error_message = "host_and_path_scoped_statement.host_header, uri_path_prefix, and every entry in excluded_uri_path_prefixes must be lowercase, and uri_path_prefix + each excluded prefix must begin with '/' (WAF applies LOWERCASE to the request field but does not transform the search_string; uri_path always begins with '/')."
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

  # Validation 9: rate_based_statement.limit must be within AWS WAF bounds and
  # aggregate_key_type must be IP or CONSTANT (FORWARDED_IP / CUSTOM_KEYS would
  # require forwarded_ip_config / custom_key blocks the module does not
  # render). CONSTANT counts all matching requests under one key, which AWS WAF
  # only accepts together with a scope_down_statement.
  validation {
    condition = alltrue([
      for v in var.rules :
      v.rate_based_statement.limit >= 10 && v.rate_based_statement.limit <= 2000000000
      && contains(["IP", "CONSTANT"], v.rate_based_statement.aggregate_key_type)
      && (v.rate_based_statement.aggregate_key_type != "CONSTANT" || try(v.rate_based_statement.scope_down_statement, null) != null)
      if try(v.rate_based_statement, null) != null
    ])
    error_message = "rate_based_statement.limit must be between 10 and 2000000000 and aggregate_key_type must be IP or CONSTANT; CONSTANT additionally requires a scope_down_statement."
  }

  # Validation 10: rate_based_statement.scope_down_statement must specify
  # exactly one of ip_set_reference_statement, not_statement, or
  # uri_path_scoped_statement, and not_statement must wrap an
  # ip_set_reference_statement.
  validation {
    condition = alltrue([
      for v in var.rules :
      (
        (try(v.rate_based_statement.scope_down_statement.ip_set_reference_statement, null) != null ? 1 : 0) +
        (try(v.rate_based_statement.scope_down_statement.not_statement, null) != null ? 1 : 0) +
        (try(v.rate_based_statement.scope_down_statement.uri_path_scoped_statement, null) != null ? 1 : 0) == 1
        ) && (
        try(v.rate_based_statement.scope_down_statement.not_statement, null) == null ||
        try(v.rate_based_statement.scope_down_statement.not_statement.ip_set_reference_statement, null) != null
      )
      if try(v.rate_based_statement.scope_down_statement, null) != null
    ])
    error_message = "rate_based_statement.scope_down_statement must specify exactly one of ip_set_reference_statement, not_statement, or uri_path_scoped_statement, and not_statement must contain an ip_set_reference_statement."
  }

  # Validation 11: uri_path_scoped_statement path prefixes must be non-empty
  # and start with "/" (byte_match on uri_path compares against the raw path,
  # so a prefix without the leading slash would never match), and host_header,
  # when set, must be non-empty.
  validation {
    condition = alltrue([
      for v in var.rules :
      startswith(v.rate_based_statement.scope_down_statement.uri_path_scoped_statement.uri_path_prefix, "/")
      && alltrue([
        for p in v.rate_based_statement.scope_down_statement.uri_path_scoped_statement.excluded_uri_path_prefixes :
        startswith(p, "/")
      ])
      && (
        v.rate_based_statement.scope_down_statement.uri_path_scoped_statement.host_header == null ||
        length(coalesce(v.rate_based_statement.scope_down_statement.uri_path_scoped_statement.host_header, "")) > 0
      )
      if try(v.rate_based_statement.scope_down_statement.uri_path_scoped_statement, null) != null
    ])
    error_message = "uri_path_scoped_statement.uri_path_prefix and every excluded_uri_path_prefixes entry must start with \"/\", and host_header, when set, must be non-empty."
  }

  # Validation 12: labeled_request_scoped_block_statement needs at least one
  # distinct, non-empty label, and exempt_methods, when set, as distinct
  # uppercase method names (the method regex is built from them and matched
  # with no text transformation).
  validation {
    condition = alltrue([
      for v in var.rules :
      length(v.labeled_request_scoped_block_statement.label_names) > 0
      && length(distinct(v.labeled_request_scoped_block_statement.label_names)) == length(v.labeled_request_scoped_block_statement.label_names)
      && alltrue([for l in v.labeled_request_scoped_block_statement.label_names : length(l) > 0])
      && length(distinct(v.labeled_request_scoped_block_statement.exempt_methods)) == length(v.labeled_request_scoped_block_statement.exempt_methods)
      && alltrue([for m in v.labeled_request_scoped_block_statement.exempt_methods : can(regex("^[A-Z]+$", m))])
      if try(v.labeled_request_scoped_block_statement, null) != null
    ])
    error_message = "labeled_request_scoped_block_statement needs at least one distinct, non-empty label_names entry, and exempt_methods (when set) as distinct uppercase HTTP method names (e.g. \"POST\")."
  }

  # Validation 12a: the path condition is mandatory and exclusive - exactly one
  # of exempt_uri_path_prefix (starting with "/") and exempt_uri_path_regex
  # (1-512 characters, the AWS WAF regex limit). Without a path condition the
  # statement would exempt whole hosts, which labeled_host_scoped_block_statement
  # already does.
  validation {
    condition = alltrue([
      for v in var.rules :
      (v.labeled_request_scoped_block_statement.exempt_uri_path_prefix != null) != (v.labeled_request_scoped_block_statement.exempt_uri_path_regex != null)
      && (v.labeled_request_scoped_block_statement.exempt_uri_path_prefix == null || startswith(coalesce(v.labeled_request_scoped_block_statement.exempt_uri_path_prefix, "/"), "/"))
      && (v.labeled_request_scoped_block_statement.exempt_uri_path_regex == null || (length(coalesce(v.labeled_request_scoped_block_statement.exempt_uri_path_regex, "")) > 0 && length(coalesce(v.labeled_request_scoped_block_statement.exempt_uri_path_regex, "")) <= 512))
      if try(v.labeled_request_scoped_block_statement, null) != null
    ])
    error_message = "labeled_request_scoped_block_statement must set exactly one of exempt_uri_path_prefix (beginning with \"/\") or exempt_uri_path_regex (1-512 characters, the AWS WAF regex limit)."
  }

  # Validation 12b: the optional host and query-string conditions. The Host
  # header is LOWERCASE-transformed before matching but the search_string is
  # not, so the suffix must be lowercase; the query-string regex is matched
  # after URL_DECODE + LOWERCASE and is subject to WAF's 512-character limit.
  validation {
    condition = alltrue([
      for v in var.rules :
      (v.labeled_request_scoped_block_statement.exempt_host_header_suffix == null || (length(coalesce(v.labeled_request_scoped_block_statement.exempt_host_header_suffix, "")) > 0 && coalesce(v.labeled_request_scoped_block_statement.exempt_host_header_suffix, "") == lower(coalesce(v.labeled_request_scoped_block_statement.exempt_host_header_suffix, ""))))
      && (v.labeled_request_scoped_block_statement.exempt_query_string_regex == null || (length(coalesce(v.labeled_request_scoped_block_statement.exempt_query_string_regex, "")) > 0 && length(coalesce(v.labeled_request_scoped_block_statement.exempt_query_string_regex, "")) <= 512))
      if try(v.labeled_request_scoped_block_statement, null) != null
    ])
    error_message = "labeled_request_scoped_block_statement exempt_host_header_suffix, when set, must be a non-empty lowercase host suffix (WAF applies LOWERCASE to the Host header but does not transform the search_string), and exempt_query_string_regex, when set, must be 1-512 characters (the AWS WAF regex limit)."
  }

  # Validation 13: uri_path_scoped_body_regex_statement needs a path prefix
  # starting with "/", a regex within AWS WAF's 512-character limit, 1 to 10
  # distinct text transformations, and a valid oversize_handling value.
  validation {
    condition = alltrue([
      for v in var.rules :
      startswith(v.uri_path_scoped_body_regex_statement.uri_path_prefix, "/")
      && length(v.uri_path_scoped_body_regex_statement.regex_string) > 0
      && length(v.uri_path_scoped_body_regex_statement.regex_string) <= 512
      && length(v.uri_path_scoped_body_regex_statement.text_transformations) > 0
      && length(v.uri_path_scoped_body_regex_statement.text_transformations) <= 10
      && length(distinct(v.uri_path_scoped_body_regex_statement.text_transformations)) == length(v.uri_path_scoped_body_regex_statement.text_transformations)
      && contains(["CONTINUE", "MATCH", "NO_MATCH"], v.uri_path_scoped_body_regex_statement.oversize_handling)
      if try(v.uri_path_scoped_body_regex_statement, null) != null
    ])
    error_message = "uri_path_scoped_body_regex_statement needs a uri_path_prefix starting with \"/\", a regex_string of 1-512 characters, 1-10 distinct text_transformations, and oversize_handling of CONTINUE, MATCH or NO_MATCH."
  }

  # Validation 14: uri_path_scoped_query_string_regex_statement needs a path
  # prefix starting with "/", a regex within AWS WAF's 512-character limit and
  # 1 to 10 distinct text transformations. There is no oversize_handling: WAF
  # inspects the whole query string.
  validation {
    condition = alltrue([
      for v in var.rules :
      startswith(v.uri_path_scoped_query_string_regex_statement.uri_path_prefix, "/")
      && length(v.uri_path_scoped_query_string_regex_statement.regex_string) > 0
      && length(v.uri_path_scoped_query_string_regex_statement.regex_string) <= 512
      && length(v.uri_path_scoped_query_string_regex_statement.text_transformations) > 0
      && length(v.uri_path_scoped_query_string_regex_statement.text_transformations) <= 10
      && length(distinct(v.uri_path_scoped_query_string_regex_statement.text_transformations)) == length(v.uri_path_scoped_query_string_regex_statement.text_transformations)
      if try(v.uri_path_scoped_query_string_regex_statement, null) != null
    ])
    error_message = "uri_path_scoped_query_string_regex_statement needs a uri_path_prefix starting with \"/\", a regex_string of 1-512 characters, and 1-10 distinct text_transformations."
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

variable "log_redacted_headers" {
  description = "Request headers blanked in WAF logs, in lower case (e.g. authorization, cookie). WAF otherwise logs bearer tokens and session cookies in clear."
  type        = list(string)
  default     = []
  nullable    = false

  validation {
    condition     = alltrue([for h in var.log_redacted_headers : trimspace(h) != "" && h == lower(h)])
    error_message = "log_redacted_headers entries must be non-empty and lower case: the AWS provider requires single_header names in lower case."
  }
}
