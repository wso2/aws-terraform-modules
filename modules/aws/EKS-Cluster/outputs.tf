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

output "eks_cluster_name" {
  value      = aws_eks_cluster.eks_cluster.name
  depends_on = [aws_eks_cluster.eks_cluster]
}
output "eks_subnet_ids" {
  value      = aws_subnet.eks_subnet.*.id
  depends_on = [aws_subnet.eks_subnet]
}
