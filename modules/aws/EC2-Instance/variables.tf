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
variable "tags" {
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
variable "application" {
  type        = string
  description = "Purpose of the EC2 Instance"
}

variable "iam_instance_profile_name" {
  type    = string
  default = null
}
variable "ssh_key_name" {
  type    = string
  default = null
}
variable "subnet_id" {
  type        = string
  description = "subnet id"
  default     = null
}
variable "vpc_security_group_ids" {
  type    = list(string)
  default = []
}
variable "root_volume_size" {
  type        = number
  description = "Type of the volume"
  default     = 20
}
variable "encrypt_root_volume" {
  type        = bool
  description = "Flag to encrypt the root volume"
  default     = true
}
variable "kms_key_id" {
  type        = string
  description = "Customer managed KMS Key ID to be used for encryption"
  default     = null
}
variable "imds_enabled" {
  type        = string
  description = "Flag to enable IMDS"
  default     = "required"
}
variable "user_data" {
  type        = string
  description = "User data to be passed to the EC2 instance"
  default     = null
}