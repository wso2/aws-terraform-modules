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

# Public ECR is a global service — the caller must configure the AWS provider
# with region = "us-east-1" (or pass an aliased us-east-1 provider).
resource "aws_ecrpublic_repository" "repository" {
  repository_name = var.repository_name
  tags            = var.tags

  dynamic "catalog_data" {
    for_each = var.description != "" ? [1] : []
    content {
      description = var.description
    }
  }
}
