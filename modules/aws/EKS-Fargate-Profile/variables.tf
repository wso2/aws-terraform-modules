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

variable "fargate_profile_name" {
  description = "Name of the fargate profile"
  type        = string
}

variable "tags" {
  description = "Tags to be associated with the EKS"
  type        = map(string)
  default     = {}
}

variable "fargate_namespaces" {
  description = "Namespaces to be used in Fargate profile"
  type        = list(string)
}

variable "subnet_ids" {
  description = "List of subnets to deploy nodepools"
  type        = list(string)
}

variable "selectors" {
  description = "List of selectors for the Fargate profile. Each selector requires a namespace and optional labels."
  type = list(object({
    namespace = string
    labels    = optional(map(string))
  }))
}
