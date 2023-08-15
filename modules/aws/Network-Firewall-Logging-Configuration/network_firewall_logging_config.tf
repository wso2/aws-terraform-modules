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

resource "aws_networkfirewall_logging_configuration" "networkfirewall_logging_configuration" {
  firewall_arn = var.firewall_arn
  logging_configuration {
    dynamic "log_destination_config" {
      for_each = var.log_destination_configs
      content {
        log_destination = {
          bucketName     = log_destination_config.value.bucket_name
          prefix         = log_destination_config.value.prefix
          deliveryStream = log_destination_config.value.delivery_stream
          logGroup       = log_destination_config.value.log_group
        }
        log_destination_type = log_destination_config.value.log_destination_type
        log_type             = log_destination_config.value.log_type
      }
    }
  }
}
