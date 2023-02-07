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

variable "ec2_vpc_id" {
  type        = string
  description = "ID of the VPC containing the EC3 instance"
}
variable "use_existing_subnet" {
  type        = bool
  description = "Flag to use existing subnet"
}
variable "vpc_subnet_id" {
  type        = string
  description = "VPC Subnet ID, required if using an pre-existing subnet"
  default     = null
}
variable "ec2_subnet_vpc_cidr_block" {
  type        = string
  description = "CIDR of the subnet which should contain the VM"
  default     = null
}
variable "availability_zone" {
  type        = string
  description = "Availability zones of the VPC Subnet"
  default     = null
}
variable "default_tags" {
  type        = map(string)
  description = "Tags to be associated with the resource"
  default     = {}
}
variable "ec2_ami" {
  type        = string
  description = "AMI to be used with the EC2 instance"
}
variable "ec2_instance_type" {
  type        = string
  description = "EC2 instance type"
}
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
  description = "Purpose of the EC2 Instance"
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