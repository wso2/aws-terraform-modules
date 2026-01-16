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

variable "eks_cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "principal_arn" {
  description = "Name of the principal ARN"
  type        = string
}

variable "kubernetes_groups" {
  description = "Kubernetes groups"
  type        = list(string)
  default     = null
}

variable "type" {
  description = "Access Entry Type"
  type        = string
  default     = "STANDARD"
}

variable "user_name" {
  description = "The user name to associate with the access entry (optional)"
  type        = string
  default     = null
}

variable "tags" {
  description = "A map of tags to assign to the resource"
  type        = map(string)
  default     = {}
}
