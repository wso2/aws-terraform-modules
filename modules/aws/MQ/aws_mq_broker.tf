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

# Ignore: AVD-AWS-0070 (https://avd.aquasec.com/misconfig/avd-aws-0070)
# Ignore: AVD-AWS-0071 (https://avd.aquasec.com/misconfig/avd-aws-0070)
# Reason: Requirement to enable logs for EKS cluster will vary based on cluster purpose and requirements (ie; Cost implications)
# This has been configured as an optional parameter
# trivy:ignore:AVD-AWS-0070
# trivy:ignore:AVD-AWS-0071
resource "aws_mq_broker" "mq" {
  broker_name = join("-", [var.project, var.application, var.environment, var.region, "mq"])

  engine_type                = "ActiveMQ"
  engine_version             = var.engine_version
  host_instance_type         = var.instance_type
  security_groups            = var.security_group_ids
  subnet_ids                 = var.subnet_ids
  publicly_accessible        = var.public_access
  auto_minor_version_upgrade = var.auto_minor_version_upgrade

  dynamic "user" {
    for_each = var.users
    content {
      username       = user.value.username
      password       = user.value.password
      console_access = user.value.console_access
    }
  }

  logs {
    audit   = var.audit_logs_enabled
    general = var.general_logs_enabled
  }
}
