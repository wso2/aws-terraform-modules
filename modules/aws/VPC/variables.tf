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

variable "vpc_cidr_block" {
  type        = string
  description = "CIDR block to be used for the VPC"
}
variable "tags" {
  type        = map(string)
  description = "Default tags to be associated with the Resource"
  default     = {}
}
variable "enable_dns_support" {
  type        = bool
  description = "Flag to enable DNS in the VPC"
  default     = true
}
variable "enable_dns_hostnames" {
  type        = bool
  description = "Flag to enable DNS host names"
  default     = false
}
variable "vpc_name" {
  description = "The name of the virtual network."
  type        = string
}
variable "vpc_abbreviation" {
  description = "The abbreviation of the resource name."
  type        = string
  default     = "vpc"
}
