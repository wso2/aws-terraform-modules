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

output "cluster_name" {
  value = mongodbatlas_cluster.cluster.name
}
output "cluster_endpoint" {
  value = mongodbatlas_cluster.cluster.mongo_uri
}
output "public_cluster_connection_string" {
  value = mongodbatlas_cluster.cluster.connection_strings[0].standard
}
output "private_cluster_connection_string" {
  value = try(mongodbatlas_cluster.cluster.connection_strings[0].private_endpoint[0].srv_connection_string, null)
}
