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

resource "aws_iam_role" "iam_for_transfer" {
  count               = length(var.structured_log_destinations) > 0 ? 1 : 0
  tags                = var.tags
  name                = join("-", [local.name_prefix, "transfer-server-log-role"])
  assume_role_policy  = data.aws_iam_policy_document.transfer_assume_role.json
  managed_policy_arns = ["arn:aws:iam::aws:policy/service-role/AWSTransferLoggingAccess"]
}

resource "aws_transfer_server" "transfer_server" {
  endpoint_type = var.endpoint_type

  logging_role                = aws_iam_role.iam_for_transfer.0.arn
  structured_log_destinations = var.structured_log_destinations

  protocols            = var.protocols
  domain               = var.domain
  security_policy_name = var.security_policy_name

  identity_provider_type = var.identity_provider_type

  url             = var.identity_provider_type == "API_GATEWAY" ? var.api_gateway_url : null
  invocation_role = var.identity_provider_type == "API_GATEWAY" ? var.invocation_role : null

  directory_id = var.identity_provider_type == "AWS_DIRECTORY_SERVICE" ? var.directory_id : null

  function = var.identity_provider_type == "AWS_LAMBDA" ? var.function : null

  dynamic "endpoint_details" {
    for_each = var.endpoint_type == "VPC_ENDPOINT" || var.endpoint_type == "VPC" ? [1] : []
    content {
      vpc_id             = var.endpoint_type == "VPC" ? var.vpc_id : null
      subnet_ids         = var.endpoint_type == "VPC" ? var.subnet_ids : null
      security_group_ids = var.endpoint_type == "VPC" ? var.security_group_ids : null
      vpc_endpoint_id    = var.endpoint_type == "VPC_ENDPOINT" ? var.vpc_endpoint_id : null
    }
  }

  tags = local.server_tags
}
