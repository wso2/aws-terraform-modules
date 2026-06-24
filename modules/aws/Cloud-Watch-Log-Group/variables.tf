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

variable "log_group_name" {
  description = "The name of the log group to create."
  type        = string
}
variable "tags" {
  description = "Default tags for resources."
  type        = map(string)
  default     = {}
}
variable "retention_in_days" {
  description = "Number of days to retain log events."
  type        = number
  default     = 30
}
variable "kms_key_id" {
  description = "The ARN of the KMS Key to use when encrypting log data."
  type        = string
  default     = null
}
variable "resource_policy_name" {
  description = "Optional name for an aws_cloudwatch_log_resource_policy attached at the account level. When set together with resource_policy_document, a policy resource is created."
  type        = string
  default     = null
}
variable "resource_policy_document" {
  description = "Optional JSON-encoded IAM policy document for the account-level CloudWatch Logs resource policy. Used to grant services like delivery.logs.amazonaws.com permission to write to this log group."
  type        = string
  default     = null
}
