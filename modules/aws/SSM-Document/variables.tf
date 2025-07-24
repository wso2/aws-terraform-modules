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

variable "user_email" {
  description = "The user that will run the session manager"
  type        = string
  default     = "ssm-user"
}
variable "session_timeout" {
  description = "The timeout for the session manager in seconds"
  type        = number
  default     = 3600
}
variable "max_session_duration" {
  description = "The maximum session duration in seconds"
  type        = number
  default     = 43200
}
variable "cloud_watch_group_name" {
  description = "The name of the CloudWatch log group for session manager logs"
  type        = string
  default     = ""
}
