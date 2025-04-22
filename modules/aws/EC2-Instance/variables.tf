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
variable "custom_routes" {
  type = list(object({
    cidr_block = string
    ep_type    = string
    ep_id      = string
  }))
  description = "Rules to be associated with the EC2 Subnet if provided"
  default     = []
}
variable "ip_address_allocation_method" {
  type        = string
  description = "How to allocate an IP address, Static, Dynamic"
}
variable "ip_type" {
  type        = string
  description = "IP Type, Public, Private"
}
variable "private_ip" {
  type        = string
  description = "Private IP for the EC2 instance, required if ip_type is Static"
  default     = null
}
variable "add_ssh_key" {
  type        = bool
  description = "Flag to add SSH key to VM"
  default     = false
}
variable "ssh_public_key" {
  type        = string
  description = "SSH Public key for EC2 Instance"
  default     = null
}
variable "security_group_ids" {
  type        = list(string)
  description = "List of security groups to be associated with the EC2 instance"
  default     = []
}
variable "enable_session_manager" {
  type        = bool
  description = "Flag to enable session manager"
  default     = true
}
variable "enable_instance_connect" {
  type        = bool
  description = "Flag to enable instance connect"
  default     = false
}
variable "kms_key_id" {
  type        = string
  description = "KMS Key ID to be used for encryption"
  default     = null
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
variable "enable_shield_protection" {
  type        = bool
  description = "Flag to enable shield protection"
  default     = false
}
