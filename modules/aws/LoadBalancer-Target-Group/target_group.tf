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

resource "aws_lb_target_group" "lb_target_group" {
  name        = join("-", [var.target_group_abbreviation, var.target_group_name])
  target_type = var.target_type
  port        = var.port
  protocol    = var.protocol
  vpc_id      = var.vpc_id
  tags        = var.tags
}

# Create target group attachments for each
resource "aws_lb_target_group_attachment" "lb_target_group_attachment" {
  for_each          = var.target_group_attachments
  target_group_arn  = aws_lb_target_group.lb_target_group.arn
  target_id         = each.value.target_id
  availability_zone = each.value.availability_zone
  port              = each.value.port
  depends_on        = [aws_lb_target_group.lb_target_group]
}
