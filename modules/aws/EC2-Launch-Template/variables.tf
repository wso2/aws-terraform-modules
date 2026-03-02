# -------------------------------------------------------------------------------------
#
# Copyright (c) 2026, WSO2 LLC. (http://www.wso2.com). All Rights Reserved.
#
# This software is the property of WSO2 LLC. and its suppliers, if any.
# Dissemination of any information or reproduction of any material contained
# herein in any form is strictly forbidden, unless permitted by WSO2 expressly.
# You may not alter or remove any copyright or other notice from copies of this content.
#
# --------------------------------------------------------------------------------------

variable "project" {
  description = "The name of the project to which the launch template belongs"
  type        = string
}

variable "environment" {
  description = "The environment to which the launch template belongs (e.g., dev, staging, prod)"
  type        = string
}

variable "application" {
  description = "The name of the application to which the launch template belongs"
  type        = string
}

variable "region" {
  description = "The AWS region in which to create the launch template"
  type        = string
}

variable "name" {
  description = "The name of the launch template"
  type        = string
}

variable "image_id" {
  description = "The ID of the AMI to use for the launch template"
  type        = string
}

variable "instance_type" {
  description = "The instance type to use for the launch template"
  type        = string
}

variable "ssh_public_key" {
  description = "The SSH public key to use for the key pair"
  type        = string
}

variable "security_group_ids" {
  description = "The security group IDs to associate with the launch template"
  type        = list(string)
}

variable "iam_instance_profile_name" {
  description = "The name of the IAM instance profile to associate with the launch template"
  type        = string
}

variable "block_device_mappings" {
  description = "Block device mappings for the launch template. This should be a list of maps, where each map contains the device name and EBS configuration for a block device."
  type = list(object({
    device_name = string
    ebs = object({
      delete_on_termination = optional(bool, true)
      volume_size           = number
      volume_type           = string
      encrypted             = optional(bool, true)
    })
  }))
  default = []
}

variable "metadata_options" {
  description = "Metadata options for the launch template (IMDSv2 settings)"
  type = object({
    http_endpoint               = optional(string, "enabled")
    http_tokens                 = optional(string, "required")
    http_put_response_hop_limit = optional(number, 1)
    instance_metadata_tags      = optional(string, "disabled")
    http_protocol_ipv6          = optional(string, "disabled")
  })
  default = {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
    instance_metadata_tags      = "disabled"
    http_protocol_ipv6          = "disabled"
  }
}

variable "user_data" {
  description = "User data to provide when launching an instance from the launch template. This should be a base64-encoded string."
  type        = string
  default     = null
}

variable "tag_specifications" {
  description = "Tag specifications for the launch template. The key is the resource type and the value is a map of tags to apply to that resource type."
  type = list(object({
    resource_type = string
    tags          = map(string)
  }))
  default = []
}

variable "tags" {
  description = "Tags to apply to the launch template and its resources"
  type        = map(string)
  default     = {}
}
