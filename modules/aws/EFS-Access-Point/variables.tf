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

variable "file_system_id" {
  description = "The ID of the EFS file system."
  type        = string
}

variable "posix_user_gid" {
  description = "The group ID for the POSIX-compatible user."
  type        = number
}

variable "posix_user_uid" {
  description = "The user ID for the POSIX-compatible user."
  type        = number
}

variable "root_directory_path" {
  description = "The path to the root directory of the access point."
  type        = string
}

variable "owner_gid" {
  description = "The group ID for the root directory owner."
  type        = number
}

variable "owner_uid" {
  description = "The user ID for the root directory owner."
  type        = number
}

variable "permissions" {
  description = "The permissions for the root directory."
  type        = string
}

variable "tags" {
  description = "A map of tags to apply to the EFS Access Point."
  type        = map(string)
}
