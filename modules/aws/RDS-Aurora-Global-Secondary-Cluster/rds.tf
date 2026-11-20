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

# Read only secondary member of an Aurora Global Database that inherits the master user and database from the primary
resource "aws_rds_cluster" "rds_cluster" {
  cluster_identifier        = local.cluster_name
  global_cluster_identifier = var.global_cluster_identifier

  engine         = var.engine
  engine_version = var.engine_version
  engine_mode    = "provisioned"

  db_subnet_group_name   = var.db_subnet_group_name
  vpc_security_group_ids = var.vpc_security_group_ids
  port                   = var.database_port

  # Encrypted cross region secondaries need a key from their own region
  storage_encrypted = true
  kms_key_id        = var.kms_key_id

  iam_database_authentication_enabled = var.iam_database_authentication_enabled
  enabled_cloudwatch_logs_exports     = var.enabled_cloudwatch_log_exports
  engine_lifecycle_support            = var.engine_lifecycle_support

  skip_final_snapshot       = var.skip_final_snapshot
  final_snapshot_identifier = var.skip_final_snapshot ? null : join("-", [local.cluster_name, "final", "snapshot"])
  deletion_protection       = var.deletion_protection

  dynamic "serverlessv2_scaling_configuration" {
    for_each = var.max_capacity == null ? [] : [1]
    content {
      min_capacity = var.min_capacity
      max_capacity = var.max_capacity
    }
  }

  # AWS sets replication_source_identifier when the cluster joins the global database
  lifecycle {
    ignore_changes = [replication_source_identifier]
  }

  tags = var.tags
}

resource "aws_rds_cluster_instance" "cluster_instances" {
  for_each           = var.cluster_instances
  identifier         = coalesce(each.value.instance_name_override, "${local.cluster_name}-${each.value.name}")
  cluster_identifier = aws_rds_cluster.rds_cluster.id
  instance_class     = each.value.instance_class
  engine             = aws_rds_cluster.rds_cluster.engine
  engine_version     = aws_rds_cluster.rds_cluster.engine_version

  tags = var.tags
}
