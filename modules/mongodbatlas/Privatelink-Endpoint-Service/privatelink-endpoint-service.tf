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

resource "mongodbatlas_privatelink_endpoint_service" "privatelink_endpoint_service" {
  project_id          = var.project_id
  private_link_id     = var.private_link_id
  endpoint_service_id = var.endpoint_service_id
  provider_name       = "AWS"
}
