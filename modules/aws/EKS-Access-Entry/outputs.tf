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

output "access_entry_arn" {
  description = "The ARN of the EKS access entry"
  value       = aws_eks_access_entry.eks_access_entry.access_entry_arn
}

output "principal_arn" {
  description = "The principal ARN of the access entry"
  value       = aws_eks_access_entry.eks_access_entry.principal_arn
}

output "cluster_name" {
  description = "The EKS cluster name"
  value       = aws_eks_access_entry.eks_access_entry.cluster_name
}
