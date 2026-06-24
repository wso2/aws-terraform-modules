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

# Ignore: AVD-AWS-0017 (https://avd.aquasec.com/misconfig/aws/ec2/avd-aws-0017)
# Reason: Variable KMS_KEY_ID is defined and can be used for explicit key encryption
# trivy:ignore:AVD-AWS-0017
resource "aws_cloudwatch_log_group" "log_group" {
  name              = var.log_group_name
  retention_in_days = var.retention_in_days
  kms_key_id        = var.kms_key_id
  tags              = var.tags
}

# Account-level resource policy granting external AWS services
# (e.g. delivery.logs.amazonaws.com for WAF/NetworkFirewall log delivery)
# permission to write to CloudWatch Logs. Created only when both inputs are set.
resource "aws_cloudwatch_log_resource_policy" "log_resource_policy" {
  count           = var.resource_policy_name != null && var.resource_policy_document != null ? 1 : 0
  policy_name     = var.resource_policy_name
  policy_document = var.resource_policy_document
}
