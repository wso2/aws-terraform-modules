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

output "ec2-instance-arn" {
  value      = aws_instance.ec2_instance.arn
  depends_on = [aws_instance.ec2_instance]
}

output "ec2-instance-id" {
  value      = aws_instance.ec2_instance.id
  depends_on = [aws_instance.ec2_instance]
}

output "ec2-instance-role-name" {
  value      = aws_iam_role.iam_role.name
  depends_on = [aws_iam_role.iam_role]
}

output "ec2-instance-role-arn" {
  value      = aws_iam_role.iam_role.arn
  depends_on = [aws_iam_role.iam_role]
}

output "ec2-instance-subnet-id" {
  value      = var.use_existing_subnet ? null : aws_subnet.ec2_subnet[0].id
  depends_on = [aws_subnet.ec2_subnet]
}

output "ec2-instance-subnet-arn" {
  value      = var.use_existing_subnet ? null : aws_subnet.ec2_subnet[0].arn
  depends_on = [aws_subnet.ec2_subnet]
}

output "ec2-instance-route-table-id" {
  value      = var.use_existing_subnet ? null : aws_route_table.route_table[0].id
  depends_on = [aws_route_table.route_table]
}

output "ec2-instance-route-table-arn" {
  value      = var.use_existing_subnet ? null : aws_route_table.route_table[0].arn
  depends_on = [aws_route_table.route_table]
}

output "ec2-instance-profile-arn" {
  value      = aws_iam_instance_profile.iam_instance_profile.arn
  depends_on = [aws_iam_instance_profile.iam_instance_profile]
}
