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
  description = "Base name for the delivery source and delivery destination, used unless source_name/destination_name override it (e.g. when adopting an existing pipeline whose source/destination were already named independently)."
  type        = string
}

variable "source_name" {
  description = "Overrides name for just the delivery source - e.g. to match an existing \"CreatedByCloudFront-...\" name when importing a pipeline that already existed."
  type        = string
  default     = null
}

variable "destination_name" {
  description = "Overrides name for just the delivery destination - e.g. to match an existing name when importing a pipeline that already existed."
  type        = string
  default     = null
}

variable "log_type" {
  description = "The log type emitted by the source AWS resource, e.g. \"ACCESS_LOGS\" for a CloudFront distribution."
  type        = string
}

variable "resource_arn" {
  description = "ARN of the AWS resource emitting the logs (e.g. a CloudFront distribution ARN)."
  type        = string
}

variable "destination_resource_arn" {
  description = "ARN of the destination resource (e.g. a CloudWatch Log Group ARN). AWS infers the destination type (CWL/S3/FH) from this ARN itself - there's no separate type argument to set."
  type        = string
}

variable "output_format" {
  description = "Log record format AWS delivers in. Valid values depend on the log_type/destination combination (see AWS's vended-logs docs) - CloudFront ACCESS_LOGS to a CloudWatch Logs destination only supports \"json\"."
  type        = string
  default     = "json"
}

variable "tags" {
  description = "Tags applied to the delivery source, destination, and delivery link."
  type        = map(string)
  default     = {}
}
