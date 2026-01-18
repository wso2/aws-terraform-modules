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

variable "db_subnet_group_name" {
  description = "Name of the DB Subnet Group"
  type        = string
}

variable "db_subnet_group_abbreviation" {
  type        = string
  description = "Abbreviation for the DB Subnet Group"
  default     = "db-sg"
}

variable "subnet_ids" {
  type        = list(string)
  description = "Subnet IDs"
}

variable "tags" {
  type        = map(string)
  description = "Tags for the Resource"
  default     = {}
}
