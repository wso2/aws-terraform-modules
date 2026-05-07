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
  type        = string
}
variable "name" {
  description = "Name of the record"
  type        = string
}
variable "ttl" {
  description = "Time to Live of the record. Must be null when alias_dns_name is set."
  type        = number
  default     = null
}
variable "type" {
  description = "Type of the DNS record (e.g. A, CNAME, NS)"
  type        = string
}
variable "records" {
  description = "Records to be associated with the DNS entry. Must be null when alias_dns_name is set."
  type        = list(string)
  default     = null
}
variable "alias_dns_name" {
  description = "The DNS name of the target for an alias record (e.g. an ELB hostname). When set, ttl and records must be null."
  type        = string
  default     = null
}
variable "alias_hosted_zone_id" {
  description = "The hosted zone ID of the alias target (e.g. the ELB's AWS-owned hosted zone ID). Required when alias_dns_name is set."
  type        = string
  default     = null
}
variable "alias_evaluate_target_health" {
  description = "Whether to evaluate the health of the alias target."
  type        = bool
  default     = true
}
