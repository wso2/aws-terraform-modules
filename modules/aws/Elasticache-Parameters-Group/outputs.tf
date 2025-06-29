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

output "elasticache_parameters_group_id" {
  value = aws_elasticache_parameter_group.elasticache_parameter_group.id
}
output "elasticache_parameters_group_name" {
  value = aws_elasticache_parameter_group.elasticache_parameter_group.name
}
output "elasticache_parameters_group_arn" {
  value = aws_elasticache_parameter_group.elasticache_parameter_group.arn
}
