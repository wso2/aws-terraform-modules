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

variable "nat_gateway_name" {
  type        = string
  description = "The name for the NAT Gateway"
}

variable "nat_gateway_abbreviation" {
  type        = string
  description = "The abbreviation for the NAT Gateway resource name"
  default     = "natg"
}

variable "eip_abbreviation" {
  type        = string
  description = "The abbreviation for the Elastic IP resource name"
  default     = "eip"
}

variable "shield_abbreviation" {
  type        = string
  description = "The abbreviation for the Shield Protection resource name"
  default     = "shld"
}

variable "tags" {
  type        = map(string)
  description = "Default tags to be associated with the Resource"
  default     = {}
}
variable "subnet_id" {
  type        = string
  description = "ID of the Subnet to host the NAT Gateway"
  default     = null
}
variable "enable_shield_protection" {
  type        = bool
  description = "Enable AWS Shield Protection for the NAT Gateway"
  default     = false
}
