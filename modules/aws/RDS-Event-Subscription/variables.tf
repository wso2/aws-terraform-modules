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
  description = "Name of the event subscription."
  type        = string
}

variable "sns_topic_arn" {
  description = "ARN of the SNS topic that receives the events. A topic encrypted with a customer managed key must allow events.rds.amazonaws.com to use the key."
  type        = string
}

variable "source_type" {
  description = "Type of source that generates the events: db-instance, db-cluster, db-parameter-group, db-security-group, db-snapshot, db-cluster-snapshot, db-proxy or custom-engine-version. When null, events from all sources are sent."
  type        = string
  default     = null
}

variable "source_ids" {
  description = "Identifiers of the sources to subscribe to, of the given source_type. When empty, events from all sources of that type are sent."
  type        = list(string)
  default     = []
}

variable "event_categories" {
  description = "Event categories to subscribe to (for example failover, failure, maintenance). When empty, all categories are sent."
  type        = list(string)
  default     = []
}

variable "enabled" {
  description = "Whether the subscription is active."
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags to add to the event subscription."
  type        = map(string)
  default     = {}
}
