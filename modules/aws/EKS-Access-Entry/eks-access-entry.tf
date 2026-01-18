# -------------------------------------------------------------------------------------
#
# Copyright (c) 2025, WSO2 LLC. (http://www.wso2.com). All Rights Reserved.
#
# This software is the property of WSO2 LLC. and its suppliers, if any.
# Dissemination of any information or reproduction of any material contained
# herein in any form is strictly forbidden, unless permitted by WSO2 expressly.
# You may not alter or remove any copyright or other notice from copies of this content.
#
# --------------------------------------------------------------------------------------

resource "aws_eks_access_entry" "eks_access_entry" {
  cluster_name      = var.eks_cluster_name
  principal_arn     = var.principal_arn
  kubernetes_groups = var.kubernetes_groups
  type              = var.type

  lifecycle {
    prevent_destroy = false
  }
}
