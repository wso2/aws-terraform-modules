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

variable "availability_zone_name" {
  description = "The name of the availability zone"
  type        = string
  default     = null
}
variable "encrypted" {
  description = "Whether the volume should be encrypted"
  type        = bool
  default     = null
}
variable "kms_key_id" {
  description = "The ARN of the AWS Key Management Service (AWS KMS) customer master key (CMK) to be used to protect the volume encryption key for the volume"
  type        = string
  default     = null
}
variable "performance_mode" {
  description = "The performance mode of the file system"
  type        = string
  default     = "generalPurpose"
}
variable "throughput_mode" {
  description = "Throughput mode for the file system"
  type        = string
  default     = "bursting"
}
variable "provisioned_throughput_in_mibps" {
  description = "The throughput, measured in MiB/s, that you want to provision for the file system"
  type        = number
  default     = null
}
variable "efs_access_points" {
  description = "An array of Amazon EFS access point ARNs that apply to the file system"
  type = map(object({
    posix_user = optional(object({
      gid = number
      uid = number
    }))
    root_directory = optional(object({
      creation_info = optional(object({
        owner_gid   = number
        owner_uid   = number
        permissions = string
      }))
      path = string
    }))
  }))
  default = {}
}
variable "efs_mount_targets" {
  description = "An array of Amazon EFS mount target objects"
  type = map(object({
    ip_address      = optional(string)
    security_groups = list(string)
    subnet_id       = string
  }))
  default = {}
}
