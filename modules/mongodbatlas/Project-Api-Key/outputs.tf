# Copyright (c) 2025, WSO2 Inc. (http://www.wso2.com). All Rights Reserved.
#
# This software is the property of WSO2 Inc. and its suppliers, if any.
# Dissemination of any information or reproduction of any material contained
# herein in any form is strictly forbidden, unless permitted by WSO2 expressly.
# You may not alter or remove any copyright or other notice from copies of this content.
#
# --------------------------------------------------------------------------------------

output "api_key_id" {
  depends_on = [mongodbatlas_project_api_key.project_api_key]
  value      = mongodbatlas_project_api_key.project_api_key.api_key_id
}

output "public_key" {
  depends_on = [mongodbatlas_project_api_key.project_api_key]
  value      = mongodbatlas_project_api_key.project_api_key.public_key
}

output "private_key" {
  depends_on = [mongodbatlas_project_api_key.project_api_key]
  value      = mongodbatlas_project_api_key.project_api_key.private_key
  sensitive  = true
}
