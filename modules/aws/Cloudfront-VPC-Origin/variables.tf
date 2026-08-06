# -------------------------------------------------------------------------------------
#
# Copyright (c) 2026, WSO2 LLC. (https://www.wso2.com) All Rights Reserved.
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
  description = "Name of the CloudFront VPC origin"
  type        = string
}

variable "origin_arn" {
  description = "ARN of the internal ALB / NLB / EC2 the VPC origin points to"
  type        = string
}

variable "http_port" {
  description = "HTTP port CloudFront uses to connect to the origin"
  type        = number
  default     = 80
}

variable "https_port" {
  description = "HTTPS port CloudFront uses to connect to the origin"
  type        = number
  default     = 443
}

variable "origin_protocol_policy" {
  description = "Origin protocol policy (http-only, https-only, match-viewer)"
  type        = string
  default     = "https-only"
}

variable "origin_ssl_protocols" {
  description = "SSL/TLS protocols CloudFront uses when connecting to the origin over HTTPS"
  type        = list(string)
  default     = ["TLSv1.2"]
}

variable "tags" {
  description = "Tags to apply to the VPC origin"
  type        = map(string)
  default     = {}
}
