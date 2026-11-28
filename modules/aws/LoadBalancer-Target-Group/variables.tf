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
  description = "Purpose of the EC2 Instance"
}
variable "target_type" {
  type        = string
  description = "Type of the target"
}
variable "port" {
  type        = number
  description = "Primary port to be exposed within the Target Group"
}
variable "protocol" {
  type        = string
  description = "Protocol to be used for the Target Group"
}
variable "vpc_id" {
  type        = string
  description = "VPC ID"
}
variable "target_group_attachments" {
  type = map(object({
    target_id         = string
    availability_zone = optional(string)
    port              = optional(number)
  }))
  description = "List of target group attachments"
  default     = {}
}
variable "preserve_client_ip" {
  type        = bool
  description = "Whether client IP preservation is enabled for the target group"
  default     = null
}
variable "health_check" {
  type = object({
    enabled             = optional(bool)
    protocol            = optional(string)
    port                = optional(string)
    path                = optional(string)
    interval            = optional(number)
    timeout             = optional(number)
    healthy_threshold   = optional(number)
    unhealthy_threshold = optional(number)
    matcher             = optional(string)
  })
  description = "Health check settings of the target group. null (the default) sets no health_check block, so the target group keeps the health check it has. When a block is set, a field left unset takes the AWS provider default (port traffic-port, interval 30, healthy and unhealthy threshold 3), not the value an existing target group has now, so set every field you care about to avoid a plan that changes them. The protocol falls back to the target group protocol when that is TCP, HTTP or HTTPS, and to TCP otherwise (the provider default of HTTP would break a TCP target group). A Network Load Balancer TCP target group defaults to a healthy threshold of 5 and an unhealthy threshold of 2, so a target is marked unhealthy after about 60 s at a 30 s interval; raise unhealthy_threshold (2-10) to tolerate longer stalls."
  default     = null
}
variable "tags" {
  type        = map(string)
  description = "Tags to be added to the resources"
  default     = {}
}
