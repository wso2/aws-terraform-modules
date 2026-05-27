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

variable "custom_ami_name" {
  description = "A region-unique name for the AMI."
  type        = string
}

variable "custom_ami_description" {
  description = "A longer, human-readable description for the AMI."
  type        = string
  default     = null
}

variable "custom_ami_architecture" {
  description = "Machine architecture for created instances. Defaults to arm64."
  type        = string
  default     = "arm64"
}

variable "custom_ami_virtualization_type" {
  description = "Keyword to choose what virtualization mode created instances will use."
  type        = string
  default     = "hvm"
}

variable "custom_ami_imds_support" {
  description = "If v2.0 is selected, EC2 instances will only support IMDSv2."
  type        = string
  default     = "v2.0"
}

variable "custom_ami_tags" {
  description = "A map of tags to assign to the resource."
  type        = map(string)
}
