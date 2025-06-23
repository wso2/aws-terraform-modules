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

variable "peer_account_id" {
  description = "The AWS account ID of the peer transit gateway"
  type        = string
}
variable "peer_region" {
  description = "The AWS region of the peer transit gateway"
  type        = string
}
variable "peer_transit_gateway_id" {
  description = "The ID of the peer transit gateway"
  type        = string
}
variable "local_transit_gateway_id" {
  description = "The ID of the local transit gateway"
  type        = string
}
variable "default_tags" {
  description = "Default tags to apply to the transit gateway peering attachment"
  type        = map(string)
  default     = {}
}
