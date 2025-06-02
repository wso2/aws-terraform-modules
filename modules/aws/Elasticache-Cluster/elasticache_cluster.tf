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

resource "aws_elasticache_replication_group" "elasticache_replication_group" {
  engine                     = var.engine
  engine_version             = var.engine_version
  transit_encryption_enabled = var.enable_transit_encryption
  auth_token                 = var.auth_token
  at_rest_encryption_enabled = var.at_rest_encryption_enabled
  num_cache_clusters         = var.num_cache_clusters
  automatic_failover_enabled = var.automatic_failover_enabled
  replication_group_id       = join("-", [var.project, var.application, var.environment, var.region, "ec-rds-rg"])
  node_type                  = var.node_type

  parameter_group_name = var.parameter_group_name
  port                 = var.port
  subnet_group_name    = var.subnet_group_name
  security_group_ids   = var.security_group_ids

  preferred_cache_cluster_azs = var.availability_zones

  snapshot_window          = var.snapshot_window
  maintenance_window       = var.maintenance_window
  snapshot_retention_limit = var.snapshot_retention_limit

  final_snapshot_identifier = var.final_snapshot_identifier

  apply_immediately          = var.apply_immediately
  auto_minor_version_upgrade = var.auto_minor_version_upgrade

  tags = var.tags

  description = "Elasticache Replication Group for ${var.project}-${var.application}-${var.environment}-${var.region}"

}
