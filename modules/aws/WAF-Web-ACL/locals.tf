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

locals {
  # Per-rule exempt scopes for labeled_request_scoped_block_statement: the
  # exempt_scopes list, or one scope built from the exempt_* fields when
  # exempt_scopes is unset. Both are normalised to the same shape so the
  # conditions below are built one way.
  labeled_request_scoped_exempt_scope_inputs = {
    for k, r in var.rules : k => (
      r.labeled_request_scoped_block_statement.exempt_scopes != null ? [
        for s in r.labeled_request_scoped_block_statement.exempt_scopes : {
          legacy             = false
          host_header_suffix = s.host_header_suffix
          uri_path_prefix    = s.uri_path_prefix
          uri_path_regex     = s.uri_path_regex
          methods            = s.methods
          query_string_regex = s.query_string_regex
          query_string_match = s.query_string_match
          body_regex         = s.body_regex
        }
        ] : [{
          legacy             = true
          host_header_suffix = r.labeled_request_scoped_block_statement.exempt_host_header_suffix
          uri_path_prefix    = r.labeled_request_scoped_block_statement.exempt_uri_path_prefix
          uri_path_regex     = r.labeled_request_scoped_block_statement.exempt_uri_path_regex
          methods            = r.labeled_request_scoped_block_statement.exempt_methods
          query_string_regex = r.labeled_request_scoped_block_statement.exempt_query_string_regex
          query_string_match = "decoded"
          body_regex         = null
      }]
    )
    if r.labeled_request_scoped_block_statement != null
  }

  # Per-rule exempt conditions, one list per scope, keyed by the var.rules map
  # key, so a rule looks its own scopes up with rule.key while rendering. Each
  # element of a scope is a self-describing match so waf_web_acl.tf can render
  # every scope uniformly, whether it carries one condition (NOT(<condition>))
  # or several (NOT(AND(<condition>, ...))).
  #
  # Field meanings:
  #   type            "byte_match" or "regex_match", picking the statement block
  #   match           search_string (byte_match) or regex_string (regex_match)
  #   constraint      positional_constraint; "" for regex_match
  #   field           request field: uri_path, query_string, method, host or body
  #   transformations text transformation types, applied at priority = index
  #
  # Order is fixed (host, path, method, query string, body) so a scope's
  # rendering does not shift when an optional condition is added, and a scope
  # built from the exempt_* fields renders exactly as before exempt_scopes
  # existed. Legacy hosts keep LOWERCASE; exempt_scopes hosts, raw queries
  # and bodies use NONE for case-sensitive matching at lower WCU cost.
  # Decoded queries keep URL_DECODE + LOWERCASE, and paths keep URL_DECODE
  # + NORMALIZE_PATH.
  labeled_request_scoped_exempt_scopes = {
    for k, scopes in local.labeled_request_scoped_exempt_scope_inputs : k => [
      for s in scopes : concat(
        s.host_header_suffix != null ? [{
          type            = "byte_match"
          match           = s.host_header_suffix
          constraint      = "ENDS_WITH"
          field           = "host"
          transformations = s.legacy ? ["LOWERCASE"] : ["NONE"]
        }] : [],
        s.uri_path_prefix != null ? [{
          type            = "byte_match"
          match           = s.uri_path_prefix
          constraint      = "STARTS_WITH"
          field           = "uri_path"
          transformations = ["URL_DECODE", "NORMALIZE_PATH"]
        }] : [],
        s.uri_path_regex != null ? [{
          type            = "regex_match"
          match           = s.uri_path_regex
          constraint      = ""
          field           = "uri_path"
          transformations = ["URL_DECODE", "NORMALIZE_PATH"]
        }] : [],
        length(s.methods) > 0 ? [{
          type            = "regex_match"
          match           = "^(?:${join("|", s.methods)})$"
          constraint      = ""
          field           = "method"
          transformations = ["NONE"]
        }] : [],
        s.query_string_regex != null ? [{
          type            = "regex_match"
          match           = s.query_string_regex
          constraint      = ""
          field           = "query_string"
          transformations = s.query_string_match == "raw" ? ["NONE"] : ["URL_DECODE", "LOWERCASE"]
        }] : [],
        s.body_regex != null ? [{
          type            = "regex_match"
          match           = s.body_regex
          constraint      = ""
          field           = "body"
          transformations = ["NONE"]
        }] : [],
      )
    ]
  }

  # Per-rule field list for multi_field_regex_statement, keyed by the var.rules
  # map key like the exempt conditions above. Each element names the request
  # field and the text transformations applied to it (the body has its own
  # list, so JSON escapes can be decoded there without touching the path).
  multi_field_regex_fields = {
    for k, r in var.rules : k => [
      for f in r.multi_field_regex_statement.fields : {
        field           = f
        transformations = f == "body" ? r.multi_field_regex_statement.body_text_transformations : r.multi_field_regex_statement.text_transformations
      }
    ]
    if r.multi_field_regex_statement != null
  }
}
