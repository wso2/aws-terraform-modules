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

variable "load_balancer_arn" {
  type        = string
  description = "The ARN of the load balancer"
}
variable "certificate_arn" {
  type        = string
  description = "The ARN of the certificate"
  default     = null
}
variable "alpn_policy" {
  type        = string
  description = "The name of the Application-Layer Protocol Negotiation (ALPN) policy. Instance target groups cannot be associated with an Application Load Balancer if the ALPN policy is not set to HTTP1Only. The valid values are HTTP1Only, HTTP2Only, and HTTP2Optional. The default is HTTP1Only."
  default     = null
}
variable "port" {
  type        = number
  description = "The port on which the load balancer is listening. You cannot specify a port for a Gateway Load Balancer."
}
variable "protocol" {
  type        = string
  description = "The protocol for connections from clients to the load balancer. For Application Load Balancers, the supported protocols are HTTP and HTTPS. For Network Load Balancers, the supported protocols are TCP, TLS, UDP, and TCP_UDP. You can’t specify the UDP or TCP_UDP protocol if dual-stack mode is enabled. You cannot specify a protocol for a Gateway Load Balancer."
  default     = null
}
variable "ssl_policy" {
  type        = string
  description = "The security policy that defines which protocols and ciphers are supported. For more information, see Security Policies in the Application Load Balancers Guide and Security Policies in the Network Load Balancers Guide."
  default     = null
}
variable "default_tags" {
  type        = map(string)
  description = "Default tags for the resource"
  default     = {}
}
variable "default_action_type" {
  type        = string
  description = "The type of action to perform. For Application Load Balancers, valid types are forward, redirect, fixed-response, and authenticate-cognito. For Network Load Balancers, valid types are forward, redirect, and fixed-response."
}
variable "target_group_arn" {
  type        = string
  description = "Target group arn for forwarding rule"
  default     = null
}
variable "forward_rule" {
  type = object({
    target_groups = optional(list(object({
      target_group_arn = string
      weight           = optional(number)
    })))
    stickiness = optional(object({
      enabled  = bool
      duration = number
    }))
  })
  description = "The target group stickiness for the rule."
  default     = null
}
variable "redirect_rule" {
  type = object({
    host        = optional(string)
    path        = optional(string)
    port        = optional(string)
    protocol    = optional(string)
    query       = optional(string)
    status_code = string
  })
  description = "The redirect behavior for the rule."
  default     = null
}
variable "fixed_response_rule" {
  type = object({
    message_body = optional(string)
    status_code  = optional(string)
    content_type = string
  })
  description = "The redirect behavior for the rule."
  default     = null
}

variable "rules" {
  type = map(object({
    action_type      = string
    priority         = number
    target_group_arn = optional(string)
    fixed_response = optional(object({
      # (Required) Content type. Valid values are 'text/plain', 'text/css', 'text/html', 'application/javascript' and 'application/json'.
      content_type = string
      # (Optional) Message body.
      message_body = optional(string)
      # (Optional) HTTP response code. Valid values are 2XX, 4XX, or 5XX
      status_code = optional(string)
    }))
    forward = optional(object({

      # (Required) Set of 1-5 target group blocks.
      target_groups = optional(list(object({
        # (Required) ARN of the target group.
        arn = string
        # (Optional) Weight. The range is 0 to 999.
        weight = optional(number)
      })))

      stickiness = optional(object({
        #  (Required) Time period, in seconds, during which requests from a client should be routed to the same target group. The range is 1-604800 seconds (7 days)
        duration = number
        # (Optional) Whether target group stickiness is enabled
        enabled = optional(bool)
      }))
    }))

    redirect = optional(object({
      # (Required) HTTP redirect code. The redirect is either permanent (HTTP_301) or temporary (HTTP_302).
      status_code = string
      # (Optional) Hostname. This component is not percent-encoded. The hostname can contain #{host}. Defaults to #{host}.
      host = optional(string)
      # (Optional) Absolute path, starting with the leading "/". This component is not percent-encoded. The path can contain #{host}, #{path}, and #{port}. Defaults to /#{path}.
      path = optional(string)
      # (Optional) Port. Specify a value from 1 to 65535 or #{port}. Defaults to #{port}.
      port = optional(string)
      # (Optional) Protocol. Valid values are HTTP, HTTPS, or #{protocol}. Defaults to #{protocol}.
      protocol = optional(string)
      # (Optional) Query parameters, URL-encoded when necessary, but not percent-encoded. Do not include the leading "?". Defaults to #{query}.
      query = optional(string)
    }))
    conditions = optional(list(object({
      # (Optional) Contains a single values item which is a list of host header patterns to match. The maximum size of each pattern is 128 characters. Comparison is case insensitive. Wildcard characters supported: * (matches 0 or more characters) and ? (matches exactly 1 character). Only one pattern needs to match for the condition to be satisfied.
      host_header = optional(object({
        values = set(string)
      }))
      # (Optional) HTTP headers to match.
      http_header = optional(object({
        # (Required) Name of HTTP header to search. The maximum size is 40 characters. Comparison is case insensitive. Only RFC7240 characters are supported. Wildcards are not supported. You cannot use HTTP header condition to specify the host header, use a host-header condition instead.
        http_header_name = string
        # (Required) List of header value patterns to match. Maximum size of each pattern is 128 characters. Comparison is case insensitive. Wildcard characters supported: * (matches 0 or more characters) and ? (matches exactly 1 character). If the same header appears multiple times in the request they will be searched in order until a match is found. Only one pattern needs to match for the condition to be satisfied. To require that all of the strings are a match, create one condition block per string.
        values = set(string)
      }))
      # (Optional) Contains a single values item which is a list of HTTP request methods or verbs to match. Maximum size is 40 characters. Only allowed characters are A-Z, hyphen (-) and underscore (_). Comparison is case sensitive. Wildcards are not supported. Only one needs to match for the condition to be satisfied. AWS recommends that GET and HEAD requests are routed in the same way because the response to a HEAD request may be cached.
      http_request_method = optional(object({
        values = set(string)
      }))
      # (Optional) Contains a single values item which is a list of path patterns to match against the request URL. Maximum size of each pattern is 128 characters. Comparison is case sensitive. Wildcard characters supported: * (matches 0 or more characters) and ? (matches exactly 1 character). Only one pattern needs to match for the condition to be satisfied. Path pattern is compared only to the path of the URL, not to its query string. To compare against the query string, use a query_string condition.
      path_pattern = optional(object({
        values = set(string)
      }))
      # (Required) Query string pairs or values to match. Multiple values blocks can be specified, see example above. Maximum size of each string is 128 characters. Comparison is case insensitive. Wildcard characters supported: * (matches 0 or more characters) and ? (matches exactly 1 character). To search for a literal '*' or '?' character in a query string, escape the character with a backslash (\). Only one pair needs to match for the condition to be satisfied.
      query_string = optional(object({
        # (Optional) Query string key pattern to match.
        key = optional(string)
        # (Required) Query string value pattern to match.
        value = string
      }))
      # (Optional) Contains a single values item which is a list of source IP CIDR notations to match. You can use both IPv4 and IPv6 addresses. Wildcards are not supported. Condition is satisfied if the source IP address of the request matches one of the CIDR blocks. Condition is not satisfied by the addresses in the X-Forwarded-For header, use http_header condition instead.
      source_ip = optional(object({
        values = set(string)
      }))
    })))
  }))

  description = "Additional Rules"
}
