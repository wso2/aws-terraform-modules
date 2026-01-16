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

variable "security_group_name" {
  type        = string
  description = "The name for the Security Group"
}

variable "security_group_abbreviation" {
  type        = string
  description = "The abbreviation for the Security Group resource name"
  default     = "stg"
}

variable "security_group_description" {
  type        = string
  description = "Description of the Security Group"
}

variable "rules" {
  type = list(object({
    direction       = string
    to_port         = number
    from_port       = number
    protocol        = string
    cidr_blocks     = list(string)
    security_groups = list(string)
  }))
  description = "List of rules to be added to the security group"
}
variable "vpc_id" {
  type        = string
  description = "VPC that Security group should be associated with"
}
variable "tags" {
  type        = map(string)
  description = "Tags to be added to the security group"
  default     = {}
}
