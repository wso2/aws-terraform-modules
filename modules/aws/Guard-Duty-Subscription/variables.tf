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

variable "enable_guardduty" {
  description = "Enable AWS GuardDuty"
  type        = bool
  default     = true
}
variable "enable_s3_data_events" {
  description = "Enable S3 data events for GuardDuty"
  type        = bool
  default     = true
}
variable "enable_eks_runtime_monitoring" {
  description = "Enable EKS runtime monitoring for GuardDuty"
  type        = bool
  default     = false
}
variable "enable_eks_audit_logs" {
  description = "Enable EKS audit logs for GuardDuty"
  type        = bool
  default     = true
}
variable "enable_runtime_monitoring" {
  description = "Enable runtime monitoring for GuardDuty"
  type        = bool
  default     = true
}
variable "enable_lambda_network_logs" {
  description = "Enable Lambda network logs for GuardDuty"
  type        = bool
  default     = true
}
variable "enable_ebs_malware_protection" {
  description = "Enable EBS malware protection for GuardDuty"
  type        = bool
  default     = true
}
variable "enable_rds_login_events" {
  description = "Enable RDS login events for GuardDuty"
  type        = bool
  default     = true
}
