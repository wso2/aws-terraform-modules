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

resource "aws_security_group_rule" "security_group_rule" {
  count = length(var.rules)

  security_group_id        = var.security_group_id
  type                     = var.rules[count.index].direction
  from_port                = var.rules[count.index].from_port
  to_port                  = var.rules[count.index].to_port
  protocol                 = var.rules[count.index].protocol
  cidr_blocks              = length(var.rules[count.index].cidr_blocks) > 0 ? var.rules[count.index].cidr_blocks : null
  prefix_list_ids          = length(var.rules[count.index].prefix_list_ids) > 0 ? var.rules[count.index].prefix_list_ids : null
  source_security_group_id = length(var.rules[count.index].security_groups) > 0 ? var.rules[count.index].security_groups[0] : null
  description              = try(var.rules[count.index].description, null)
}
