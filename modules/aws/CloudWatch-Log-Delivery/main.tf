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

# Wraps AWS's unified vended-logs delivery API for services with no direct log destination argument (CloudFront standard logs, WAF, Route 53 Resolver query logs).
resource "aws_cloudwatch_log_delivery_source" "source" {
  name         = coalesce(var.source_name, var.name)
  log_type     = var.log_type
  resource_arn = var.resource_arn
  tags         = var.tags
}

resource "aws_cloudwatch_log_delivery_destination" "destination" {
  name = coalesce(var.destination_name, var.name)
  # delivery_destination_type is computed by AWS from destination_resource_arn and isn't a settable argument.
  output_format = var.output_format
  tags          = var.tags

  delivery_destination_configuration {
    destination_resource_arn = var.destination_resource_arn
  }
}

resource "aws_cloudwatch_log_delivery" "delivery" {
  delivery_source_name     = aws_cloudwatch_log_delivery_source.source.name
  delivery_destination_arn = aws_cloudwatch_log_delivery_destination.destination.arn
  tags                     = var.tags
}
