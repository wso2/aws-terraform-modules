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
  description = "Name of the CloudFront Function (unique within the account)."
  type        = string
}

variable "runtime" {
  description = "CloudFront Function runtime."
  type        = string
  default     = "cloudfront-js-2.0"

  validation {
    condition     = contains(["cloudfront-js-1.0", "cloudfront-js-2.0"], var.runtime)
    error_message = "runtime must be one of: cloudfront-js-1.0, cloudfront-js-2.0."
  }
}

variable "comment" {
  description = "Comment describing the function."
  type        = string
  default     = null
}

variable "code" {
  description = "The JavaScript source code of the function."
  type        = string
}

variable "publish" {
  description = "Whether to publish the function to the LIVE stage on create/update."
  type        = bool
  default     = true
}
