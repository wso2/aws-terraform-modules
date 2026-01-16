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

variable "elb_abbreviation" {
  description = "Abbreviation for the Elastic Load Balancer"
  type        = string
  default     = "elb"
}
variable "elb_name" {
  description = "Name of the Elastic Load Balancer"
  type        = string
}
variable "internal_usage_flag" {
  type        = string
  description = "Flag to indicate whether the EC2 instance is for internal usage or not"
  default     = false
}
variable "security_group_ids" {
  type        = list(string)
  description = "List of security group IDs"
  default     = []
}
variable "subnet_ids" {
  type        = map(string)
  description = "List of subnet IDs"
  default     = {}
}
variable "deletion_protection_flag" {
  type        = string
  description = "Flag to indicate whether the ALB instance is protected from accidental termination or not"
  default     = true
}
variable "tags" {
  type        = map(string)
  description = "Default tags to be added to the ALB instance"
  default     = {}
}
variable "load_balancer_type" {
  type        = string
  description = "Type of the load balancer"
}
variable "private_ip_addresses" {
  type        = map(string)
  description = "List of private IP addresses"
  default     = {}
}
variable "enable_shield_protection" {
  type        = string
  description = "Flag to indicate whether the ALB instance is protected by AWS Shield or not"
  default     = false
}
variable "shield_protection_abbreviation" {
  description = "Abbreviation for the Shield Protection"
  type        = string
  default     = "elb-eip-shield-protection"
}
