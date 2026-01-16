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

# trivy:ignore:AVD-AWS-0099 Description is a required variable for the security group
resource "aws_security_group" "security_group" {
  name        = local.sg_name
  description = var.security_group_description
  vpc_id      = var.vpc_id
  tags        = local.sg_tags
}

resource "aws_security_group_rule" "security_group_rule" {
  count = length(var.rules)

  security_group_id = aws_security_group.security_group.id
  type              = var.rules[count.index].direction
  from_port         = var.rules[count.index].from_port
  to_port           = var.rules[count.index].to_port
  protocol          = var.rules[count.index].protocol
  cidr_blocks       = var.rules[count.index].cidr_blocks

  depends_on = [
    aws_security_group.security_group
  ]
}
