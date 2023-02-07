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

variable "eks_cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}
variable "node_group_name" {
  type        = string
  description = "Name of the Node group"
}
variable "subnet_ids" {
  type        = list(string)
  description = "List of subnets to deploy nodepools"
}
variable "default_tags" {
  type        = string
  description = "Tags to be associated with the EKS"
  default     = {}
}
