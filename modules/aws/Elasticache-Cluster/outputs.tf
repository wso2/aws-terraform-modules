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

output "primary_endpoint_address" {
  value      = aws_elasticache_replication_group.elasticache_replication_group.primary_endpoint_address
  depends_on = [aws_elasticache_replication_group.elasticache_replication_group]
}
output "redis_cluster_id" {
  value      = aws_elasticache_replication_group.elasticache_replication_group.id
  depends_on = [aws_elasticache_replication_group.elasticache_replication_group]
}
output "node_id" {
  value      = join("-", [aws_elasticache_replication_group.elasticache_replication_group.id, "001"])
  depends_on = [aws_elasticache_replication_group.elasticache_replication_group]
}
