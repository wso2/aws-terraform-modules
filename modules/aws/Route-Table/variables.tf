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

variable "route_table_name" {
  type        = string
  description = "The name for the Route Table"
}

variable "route_table_abbreviation" {
  type        = string
  description = "The abbreviation for the Route Table resource name"
  default     = "rt"
}

variable "vpc_id" {
  type        = string
  description = "ID of the VPC containing the route table"
}

variable "tags" {
  type        = map(string)
  description = "Tags to be associated with the resource"
  default     = {}
}

variable "custom_routes" {
  type = list(object({
    cidr_block = string
    ep_type    = string
    ep_id      = string
  }))
  description = "Rules to be associated with the Subnet if provided"
  default     = []
}
