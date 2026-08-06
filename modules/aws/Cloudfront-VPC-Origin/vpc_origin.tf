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
#
# CloudFront VPC Origin — private connectivity from CloudFront to an internal ALB/NLB/EC2
# via AWS-managed ENIs (requires aws provider >= 5.82.0).
# --------------------------------------------------------------------------------------

resource "aws_cloudfront_vpc_origin" "vpc_origin" {
  vpc_origin_endpoint_config {
    name                   = var.name
    arn                    = var.origin_arn
    http_port              = var.http_port
    https_port             = var.https_port
    origin_protocol_policy = var.origin_protocol_policy

    origin_ssl_protocols {
      items    = var.origin_ssl_protocols
      quantity = length(var.origin_ssl_protocols)
    }
  }

  tags = var.tags
}
