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

resource "aws_elasticache_cluster" "single_node_elasticache_cluster" {
  cluster_id           = join("-", [var.project, var.application, var.environment, var.region, "ec-rds"])
  engine               = "redis"
  node_type            = var.node_type
  num_cache_nodes      = 1
  parameter_group_name = var.parameter_group_name
  engine_version       = var.engine_version

  apply_immediately          = var.apply_immediately
  auto_minor_version_upgrade = var.auto_minor_version_upgrade
  port                       = var.port

  availability_zone         = var.availability_zone
  final_snapshot_identifier = var.final_snapshot_identifier
  ip_discovery              = var.ip_discovery
  network_type              = var.network_type

  maintenance_window       = var.maintenance_window
  snapshot_retention_limit = var.snapshot_retention_limit
  snapshot_window          = var.snapshot_window

  security_group_ids = var.security_group_ids
  subnet_group_name  = var.subnet_group_name

  tags = var.tags
}