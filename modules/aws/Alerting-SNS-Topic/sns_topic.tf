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

# Ignore: AVD-AWS-0095 (https://avd.aquasec.com/misconfig/aws/ec2/avd-aws-0095)
# Reason: Variable KMS_KEY_ID is defined and can be used for explicit key encryption
# trivy:ignore:AVD-AWS-0095
resource "aws_sns_topic" "sns_topic" {
  name              = join("-", [var.project, var.application, var.environment, var.region, var.topic_name])
  kms_master_key_id = var.kms_master_key_id
  tags              = var.tags
}

resource "aws_sns_topic_policy" "sns_topic_policy" {
  arn = aws_sns_topic.sns_topic.arn

  policy = data.aws_iam_policy_document.sns_topic_policy.json
}

resource "aws_sns_topic_subscription" "subscription" {
  for_each = { for s in var.subscribers : s.endpoint => s }

  topic_arn = aws_sns_topic.sns_topic.arn
  protocol  = each.value.protocol
  endpoint  = each.value.endpoint

  delivery_policy = each.value.delivery_policy
}
