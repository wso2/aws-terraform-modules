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

resource "aws_rds_cluster" "rds_cluster" {

  allow_major_version_upgrade     = var.allow_major_version_upgrade
  apply_modifications_immediately = var.apply_modifications_immediately

  availability_zones = var.availability_zones
  network_type       = var.network_type
  port               = var.database_port

  backtrack_window             = var.backtrack_window
  backup_retention_period      = var.backup_retention_period
  preferred_backup_window      = var.preferred_backup_window
  preferred_maintenance_window = var.preferred_maintenance_window

  database_name               = var.database_name
  master_username             = var.master_username
  master_password             = var.master_password
  manage_master_user_password = var.master_password == null ? true : false

  db_cluster_parameter_group_name  = var.db_cluster_parameter_group_name
  db_instance_parameter_group_name = var.allow_major_version_upgrade == true ? var.db_instance_parameter_group_name : null

  enable_http_endpoint = var.engine_mode == "serverless" ? var.enable_http_endpoint : null

  engine         = var.engine
  engine_mode    = var.engine_mode
  engine_version = var.engine_version

  db_cluster_instance_class = var.db_cluster_instance_class
  db_subnet_group_name      = var.db_subnet_group_name

  global_cluster_identifier     = var.global_cluster_identifier
  replication_source_identifier = var.replication_source_identifier

  enabled_cloudwatch_logs_exports = var.enabled_cloudwatch_log_exports

  iam_database_authentication_enabled = var.iam_database_authentication_enabled

  deletion_protection = var.deletion_protection

  cluster_identifier = local.cluster_name

  dynamic "scaling_configuration" {
    for_each = var.enable_scaling_configuration == true && var.engine_mode == "serverless" ? [1] : []
    content {
      max_capacity = var.max_capacity
      min_capacity = var.min_capacity
    }
  }

  dynamic "serverlessv2_scaling_configuration" {
    for_each = var.enable_scaling_configuration == true && var.engine_mode == "provisioned" ? [1] : []
    content {
      max_capacity = var.max_capacity
      min_capacity = var.min_capacity
    }
  }

  tags = var.tags
}

resource "aws_rds_cluster_instance" "cluster_instances" {
  for_each           = var.cluster_instances
  identifier         = "${local.cluster_name}-${each.value.name}"
  cluster_identifier = aws_rds_cluster.rds_cluster.id
  instance_class     = var.db_cluster_instance_class == null ? each.value.instance_class : var.db_cluster_instance_class
  engine             = aws_rds_cluster.rds_cluster.engine
  engine_version     = aws_rds_cluster.rds_cluster.engine_version

  custom_iam_instance_profile = var.cluster_custom_iam_instance_profile == null ? each.value.custom_iam_instance_profile : var.cluster_custom_iam_instance_profile
  db_parameter_group_name     = var.db_cluster_parameter_group_name == null ? each.value.db_parameter_group_name : var.db_cluster_parameter_group_name

  monitoring_interval                            = var.cluster_common_monitoring_interval == null ? each.value.monitoring_interval : var.cluster_common_monitoring_interval
  monitoring_role_arn                            = var.cluster_common_monitoring_role_arn == null ? each.value.monitoring_role_arn : var.cluster_common_monitoring_role_arn
  performance_insights_enabled                   = var.cluster_common_performance_insights_enabled == null ? each.value.performance_insights_enabled : var.cluster_common_performance_insights_enabled
  performance_insights_insights_retention_period = var.cluster_common_performance_insights_insights_retention_period == null ? each.value.performance_insights_insights_retention_period : var.cluster_common_performance_insights_insights_retention_period

  preferred_backup_window      = var.preferred_backup_window != null ? null : each.value.preferred_backup_window
  preferred_maintenance_window = var.preferred_maintenance_window == null ? each.value.preferred_maintenance_window : var.preferred_maintenance_window

  publicly_accessible = var.publicly_accessible

  tags = var.tags

}