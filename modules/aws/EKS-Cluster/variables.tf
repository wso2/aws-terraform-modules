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

variable "project" {
  type        = string
  description = "Name of the project"
}
variable "environment" {
  type        = string
  description = "Name of the environment"
}
variable "region" {
  type        = string
  description = "Code of the region"
}
variable "padding" {
  type        = string
  description = "Padding string to differentiate resource"
  default     = "001"
}
variable "application" {
  type        = string
  description = "Purpose of the EKS Cluster"
}
variable "kubernetes_version" {
  type        = string
  description = "Kubernetes Version"
}
variable "endpoint_private_access" {
  type        = bool
  description = "Enable private access to Cluster"
  default     = true
}
variable "endpoint_public_access" {
  type        = bool
  description = "Enable public access to Cluster"
  default     = false
}
variable "public_access_cidrs" {
  type        = list(string)
  description = "Public CIDRs which can access the cluster API Server"
  default     = []
}
variable "service_ipv4_cidr" {
  type        = string
  description = "CIDR block for K8S Service"
}
variable "eks_vpc_id" {
  type        = string
  description = "ID of the VPC to create the subnets"
}
variable "subnet_details" {
  type = list(object({
    availablity_zone = string
    cidr_block       = string
  }))
  default = []
}
variable "custom_routes" {
  type = list(object({
    cidr_block = string
    ep_type    = string
    ep_id      = string
  }))
  description = "Rules to be associated with the EC2 Subnet if provided"
  default     = []
}
variable "iam_role_name" {}
variable "default_tags" {}
