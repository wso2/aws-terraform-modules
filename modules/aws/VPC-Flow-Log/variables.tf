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

variable "log_destination" {
  type = string
  description = "The log destination for Flow Log"
}
variable "log_destination_type" {
    type = string
    description = "The log destination type for Flow Log"
}
variable "traffic_type" {
    type = string
    description = "The traffic type for Flow Log"
}
variable "vpc_id" {
    type = string
    description = "The VPC ID which is associated with the Flow Log"
}
variable "subnet_id" {
    type = string
    description = "The Subnet ID which is associated with the Flow Log"
}
variable "tags" {
    type = map(string)
    description = "The tags for Flow Log"
}
variable "eni_id" {
    type = string
    description = "The ENI ID which is associated with the Flow Log"
}
variable "transit_gateway_id" {
    type = string
    description = "The Transit Gateway ID which is associated with the Flow Log"
}
variable "transit_gateway_attachment_id" {
    type = string
    description = "The Transit Gateway Attachment ID which is associated with the Flow Log"
}
variable "log_format" {
  type = string
  description = "The log format for Flow Log"
  default = null
}
variable 'max_aggregation_interval' {
  type = number
  description = 'The maximum interval of time during which a flow of packets is captured and aggregated into a flow log record. Measured in seconds'
  default = 600
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
  description = "Purpose of the Subnet"
}
