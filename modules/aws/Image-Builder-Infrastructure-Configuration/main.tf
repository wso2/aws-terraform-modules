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

resource "aws_imagebuilder_infrastructure_configuration" "imagebuilder_infrastructure_configuration" {
  name                          = join("-", compact([var.project, var.application, var.environment, var.region, var.name, "ib-infra-config"]))
  description                   = var.description
  instance_profile_name         = var.instance_profile_name
  instance_types                = var.instance_types
  subnet_id                     = var.subnet_id
  security_group_ids            = var.security_group_ids
  key_pair                      = var.key_pair
  sns_topic_arn                 = var.sns_topic_arn
  terminate_instance_on_failure = var.terminate_instance_on_failure
  tags                          = var.tags

  # Tags for the build and test instances Image Builder launches. Provider default_tags
  # do not reach them.
  resource_tags = var.resource_tags

  instance_metadata_options {
    http_tokens                 = var.instance_metadata_options.http_tokens
    http_put_response_hop_limit = var.instance_metadata_options.http_put_response_hop_limit
  }

  dynamic "logging" {
    for_each = var.s3_logs == null ? [] : [var.s3_logs]
    content {
      s3_logs {
        s3_bucket_name = logging.value.bucket_name
        s3_key_prefix  = logging.value.key_prefix
      }
    }
  }
}
