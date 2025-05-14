# -------------------------------------------------------------------------------------
#
# Copyright (c) 2025, WSO2 Inc. (http://www.wso2.com). All Rights Reserved.
#
# This software is the property of WSO2 Inc. and its suppliers, if any.
# Dissemination of any information or reproduction of any material contained
# herein in any form is strictly forbidden, unless permitted by WSO2 expressly.
# You may not alter or remove any copyright or other notice from copies of this content.
#
# --------------------------------------------------------------------------------------

resource "mongodbatlas_access_list_api_key" "access_list_api_key" {
  org_id     = var.org_id
  cidr_block = var.cidr_block
  api_key_id = var.api_key_id
}
