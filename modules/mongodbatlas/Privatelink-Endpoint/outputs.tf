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

output "privatelink_endpoint_id" {
  value = mongodbatlas_privatelink_endpoint.privatelink_endpoint.id
}

output "private_link_service_name" {
  value = mongodbatlas_privatelink_endpoint.privatelink_endpoint.private_link_service_name
}

output "private_link_service_resource_id" {
  value = mongodbatlas_privatelink_endpoint.privatelink_endpoint.private_link_service_resource_id
}

output "project_id" {
  value = mongodbatlas_privatelink_endpoint.privatelink_endpoint.project_id
}

output "private_link_id" {
  value = mongodbatlas_privatelink_endpoint.privatelink_endpoint.private_link_id
}

output "endpoint_service_name" {
  value = mongodbatlas_privatelink_endpoint.privatelink_endpoint.endpoint_service_name
}
