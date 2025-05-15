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

variable "cluster_name" {
  description = "The name of the EKS cluster to which the add-on will be attached."
  type        = string
}
variable "addon_name" {
  description = "The name of the add-on to be attached to the EKS cluster."
  type        = string
}
