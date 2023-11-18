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
  description = "Purpose of the Security Group"
}
variable "protocols" {
  type        = list(string)
  default     = ["sftp"]
  description = "The protocol to use when connecting to the Server. Defaults to sftp only"
}
variable "domain" {
  type        = string
  description = "The type of backend domain supported by the server, defaults to EFS"
  default     = "EFS"
}
variable "endpoint_type" {
  type        = string
  description = "The type of endpoint to use when connecting to the server. Defaults to PUBLIC"
  default     = "PUBLIC"
}
variable "structured_log_destinations" {
  type        = list(string)
  description = "The list of structured log destinations to be configured for the server"
  default     = []
}
variable "security_policy_name" {
  type        = string
  description = "The name of the security policy to be configured for the server"
  default     = "TransferSecurityPolicy-2018-11"
}
variable "identity_provider_type" {
  type        = string
  description = "Authentication mechanism to Login to the Server"
  default     = "SERVICE_MANAGED"
}
variable "api_gateway_url" {
  type        = string
  description = "The URL of the API Gateway to be configured for the server, if using API Gateway as auth mechanism"
  default     = null
}
variable "invocation_role" {
  type        = string
  description = "The ARN of the IAM role used to authenticate the user account with an identity provider of type API Gateway"
  default     = null
}
variable "function" {
  type        = string
  description = "The ARN of the Lambda function to be used authentication if used as the authentication mechanism"
  default     = null
}
variable "directory_id" {
  type        = string
  description = "The ID of the AWS Directory Service directory to be used for authentication if used as the authentication mechanism"
  default     = null
}
variable "vpc_id" {
  type        = string
  description = "The ID of the VPC in which the server should be created"
  default     = null
}
variable "subnet_ids" {
  type        = list(string)
  description = "The IDs of the subnets in which the server should be created"
  default     = []
}
variable "security_group_ids" {
  type        = list(string)
  description = "The IDs of the security groups to be associated with the server"
  default     = []
}
variable "tags" {
  type        = map(string)
  description = "The tags to be associated with the server"
  default     = {}
}
variable "vpc_endpoint_id" {
  type        = string
  description = "The ID of the VPC endpoint to be associated with the server"
  default     = null
}
