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

# Subscribe an HTTPS endpoint to an SNS topic. Uses aws.subscription so the
# subscription is created in the SNS topic's region — pass the same provider
# as the default for same-region cases.
resource "aws_sns_topic_subscription" "https_subscription" {
  provider               = aws.subscription
  topic_arn              = var.sns_arn
  protocol               = "https"
  endpoint               = var.endpoint
  endpoint_auto_confirms = var.endpoint_auto_confirms
  raw_message_delivery   = var.raw_message_delivery
  delivery_policy        = var.delivery_policy
}
