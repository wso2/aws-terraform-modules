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
      # Supports a direct byte_match_statement, a direct and_statement, or a not_statement
      # wrapping either of the above. Use not_statement+and_statement to EXCLUDE a path
      # (e.g. /oauth2/token) from a managed rule group while keeping the rest protected.
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
        and_statement = optional(object({
          statements = list(object({
            byte_match_statement = object({
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
            })
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
          and_statement = optional(object({
            statements = list(object({
              byte_match_statement = object({
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
              })
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
  }))

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
  # byte_match_statement, and_statement, or not_statement.
  validation {
    condition = alltrue([
      for v in var.rules :
      (try(v.managed_rule_group_statement.scope_down_statement.byte_match_statement, null) != null ? 1 : 0) +
      (try(v.managed_rule_group_statement.scope_down_statement.and_statement, null) != null ? 1 : 0) +
      (try(v.managed_rule_group_statement.scope_down_statement.not_statement, null) != null ? 1 : 0) == 1
      if try(v.managed_rule_group_statement.scope_down_statement, null) != null
    ])
    error_message = "managed_rule_group_statement.scope_down_statement must specify exactly one of byte_match_statement, and_statement, or not_statement."
  }

  # Validation 6: When scope_down_statement.not_statement is used, exactly one of
  # byte_match_statement or and_statement must be set under it.
  validation {
    condition = alltrue([
      for v in var.rules :
      (try(v.managed_rule_group_statement.scope_down_statement.not_statement.byte_match_statement, null) != null ? 1 : 0) +
      (try(v.managed_rule_group_statement.scope_down_statement.not_statement.and_statement, null) != null ? 1 : 0) == 1
      if try(v.managed_rule_group_statement.scope_down_statement.not_statement, null) != null
    ])
    error_message = "managed_rule_group_statement.scope_down_statement.not_statement must contain exactly one of byte_match_statement or and_statement."
  }

  # Validation 7: and_statement inside scope_down_statement (directly or under not_statement)
  # must contain >= 2 statements.
  validation {
    condition = alltrue([
      for v in var.rules :
      length(try(v.managed_rule_group_statement.scope_down_statement.and_statement.statements,
        v.managed_rule_group_statement.scope_down_statement.not_statement.and_statement.statements,
      [])) >= 2
      if try(v.managed_rule_group_statement.scope_down_statement.and_statement, v.managed_rule_group_statement.scope_down_statement.not_statement.and_statement, null) != null
    ])
    error_message = "and_statement inside scope_down_statement must contain at least 2 statements."
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
