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

variable "zone_id" {
  description = "ID of the Private DNS Zone"
  type = string
}
variable "name" {
  description = "Name of the record"
  type = string
}
variable "ttl" {
  description = "Time to Live of the record"
  type = number
}
variable "type" {
  description = "Type of the A Record"
  type = string
}
variable "records" {
  description = "Records to be associated with the DNS entry"
  type = list(string)
}
