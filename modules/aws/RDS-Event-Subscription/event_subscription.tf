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

# RDS event notifications (failover, failure, maintenance, ...) published to an SNS topic.
resource "aws_db_event_subscription" "event_subscription" {
  name             = var.name
  sns_topic        = var.sns_topic_arn
  source_type      = var.source_type
  source_ids       = var.source_ids
  event_categories = var.event_categories
  enabled          = var.enabled
  tags             = var.tags
}
