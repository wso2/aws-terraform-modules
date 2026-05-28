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

variable "ami_name" {
  description = "A region-unique name for the AMI."
  type        = string
}

variable "ami_description" {
  description = "A longer, human-readable description for the AMI."
  type        = string
  default     = null
}

variable "ami_architecture" {
  description = "Machine architecture for created instances. Defaults to arm64."
  type        = string
  default     = "arm64"
}

variable "ami_virtualization_type" {
  description = "Keyword to choose what virtualization mode created instances will use."
  type        = string
  default     = "hvm"
}

variable "ami_imds_support" {
  description = "If v2.0 is selected, EC2 instances will only support IMDSv2."
  type        = string
  default     = "v2.0"
}

variable "ami_tags" {
  description = "A map of tags to assign to the resource."
  type        = map(string)
  default     = {}
}
