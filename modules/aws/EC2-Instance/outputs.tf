# -------------------------------------------------------------------------------------
#
# Copyright (c) 2023, WSO2 LLC. (http://www.wso2.com). All Rights Reserved.
#
# This software is the property of WSO2 LLC. and its suppliers, if any.
# Dissemination of any information or reproduction of any material contained
# herein in any form is strictly forbidden, unless permitted by WSO2 expressly.
# You may not alter or remove any copyright or other notice from copies of this content.
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
output "ec2-instance-subnet-id" {
  value      = aws_subnet.ec2_subnet.id
  depends_on = [aws_subnet.ec2_subnet]
}
output "ec2-instance-subnet-arn" {
  value      = aws_subnet.ec2_subnet.arn
  depends_on = [aws_subnet.ec2_subnet]
}
output "ec2-instance-route-table-id" {
  value      = aws_route_table.route_table.id
  depends_on = [aws_route_table.route_table]
}
output "ec2-instance-route-table-arn" {
  value      = aws_route_table.route_table.arn
  depends_on = [aws_route_table.route_table]
}
