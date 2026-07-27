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

variable "detector_id" {
  description = "ID of the GuardDuty detector to attach the publishing destination to."
  type        = string
}

variable "destination_arn" {
  description = "ARN of the destination that receives exported findings. For S3 destinations this is the bucket ARN, optionally suffixed with a key prefix (e.g. arn:aws:s3:::my-audit-bucket/123456789012)."
  type        = string
}

variable "kms_key_arn" {
  description = "ARN of the KMS key GuardDuty uses to encrypt exported findings. The key policy must allow guardduty.amazonaws.com to kms:GenerateDataKey."
  type        = string
}

variable "destination_type" {
  description = "Type of the publishing destination. Only \"S3\" is currently supported by GuardDuty."
  type        = string
  default     = "S3"
}
