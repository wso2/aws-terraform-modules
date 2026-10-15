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

output "delivery_source_arn" {
  description = "ARN of the delivery source"
  value       = aws_cloudwatch_log_delivery_source.source.arn
}

output "delivery_source_name" {
  description = "Name of the delivery source"
  value       = aws_cloudwatch_log_delivery_source.source.name
}

output "delivery_destination_arn" {
  description = "ARN of the delivery destination"
  value       = aws_cloudwatch_log_delivery_destination.destination.arn
}

output "delivery_destination_type" {
  description = "Destination type AWS inferred from destination_resource_arn (\"CWL\", \"S3\", or \"FH\")"
  value       = aws_cloudwatch_log_delivery_destination.destination.delivery_destination_type
}

output "delivery_arn" {
  description = "ARN of the delivery link between the source and destination"
  value       = aws_cloudwatch_log_delivery.delivery.arn
}
