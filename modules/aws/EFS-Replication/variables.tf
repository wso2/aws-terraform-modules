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

variable "source_file_system_id" {
  description = "ID of the EFS file system to replicate"
  type        = string
}

variable "destination_region" {
  description = "Region of the destination file system"
  type        = string
  default     = null
}

variable "destination_file_system_id" {
  description = "ID of an existing destination file system or null to let EFS create one"
  type        = string
  default     = null
}

variable "destination_availability_zone_name" {
  description = "Availability zone for a One Zone destination file system created by EFS"
  type        = string
  default     = null
}

variable "destination_kms_key_id" {
  description = "KMS key for a destination file system created by EFS"
  type        = string
  default     = null
}
