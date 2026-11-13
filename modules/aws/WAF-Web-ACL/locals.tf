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
  # Per-rule exempt conditions for labeled_request_scoped_block_statement,
  # keyed by the var.rules map key, so a rule looks its own list up with
  # rule.key while rendering. Each element is a self-describing match so waf_web_acl.tf can render
  # them uniformly, whether the rule carries one condition (NOT(<condition>))
  # or several (NOT(AND(<condition>, ...))).
  #
  # Field meanings:
  #   type            "byte_match" or "regex_match", picking the statement block
  #   match           search_string (byte_match) or regex_string (regex_match)
  #   constraint      positional_constraint; "" for regex_match
  #   field           request field: uri_path, query_string, method or host
  #   transformations text transformation types, applied at priority = index
  #
  # Order is fixed (host, path, method, query string) so a rule's rendering
  # does not shift when an optional condition is added to the statement.
  labeled_request_scoped_exempt_conditions = {
    for k, r in var.rules : k => concat(
      r.labeled_request_scoped_block_statement.exempt_host_header_suffix != null ? [{
        type            = "byte_match"
        match           = r.labeled_request_scoped_block_statement.exempt_host_header_suffix
        constraint      = "ENDS_WITH"
        field           = "host"
        transformations = ["LOWERCASE"]
      }] : [],
      r.labeled_request_scoped_block_statement.exempt_uri_path_prefix != null ? [{
        type            = "byte_match"
        match           = r.labeled_request_scoped_block_statement.exempt_uri_path_prefix
        constraint      = "STARTS_WITH"
        field           = "uri_path"
        transformations = ["URL_DECODE", "NORMALIZE_PATH"]
      }] : [],
      r.labeled_request_scoped_block_statement.exempt_uri_path_regex != null ? [{
        type            = "regex_match"
        match           = r.labeled_request_scoped_block_statement.exempt_uri_path_regex
        constraint      = ""
        field           = "uri_path"
        transformations = ["URL_DECODE", "NORMALIZE_PATH"]
      }] : [],
      length(r.labeled_request_scoped_block_statement.exempt_methods) > 0 ? [{
        type            = "regex_match"
        match           = "^(${join("|", r.labeled_request_scoped_block_statement.exempt_methods)})$"
        constraint      = ""
        field           = "method"
        transformations = ["NONE"]
      }] : [],
      r.labeled_request_scoped_block_statement.exempt_query_string_regex != null ? [{
        type            = "regex_match"
        match           = r.labeled_request_scoped_block_statement.exempt_query_string_regex
        constraint      = ""
        field           = "query_string"
        transformations = ["URL_DECODE", "LOWERCASE"]
      }] : [],
    )
    if r.labeled_request_scoped_block_statement != null
  }
}
