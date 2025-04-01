locals {
  identifier                = lower(join("-", [var.project, var.application, var.environment, var.region, var.engine, "db"]))
  final_snapshot_identifier = "${local.identifier}-final-snapshot-${var.final_snapshot_identifier_suffix}"
  parameter_group_name      = "${local.identifier}-pg"
  option_group_name         = "${local.identifier}-og"
}

resource "aws_db_instance" "database" {

  identifier = local.identifier

  engine            = var.engine
  engine_version    = var.engine_version
  instance_class    = var.instance_class
  allocated_storage = var.allocated_storage
  storage_type      = var.storage_type
  storage_encrypted = var.storage_encrypted
  kms_key_id        = var.kms_key_id

  username                    = var.username
  manage_master_user_password = true
  port                        = var.port

  vpc_security_group_ids = var.vpc_security_group_ids
  db_subnet_group_name   = var.db_subnet_group_name
  parameter_group_name   = var.create_parameter_group ? aws_db_parameter_group.parameter_group[0].name : null
  option_group_name      = var.create_potion_group ? aws_db_option_group.option_group[0].name : null

  multi_az           = var.multi_az
  iops               = var.iops
  storage_throughput = var.storage_throughput
  ca_cert_identifier = var.ca_cert_identifier

  allow_major_version_upgrade = var.allow_major_version_upgrade
  maintenance_window          = var.maintenance_window

  copy_tags_to_snapshot     = true
  skip_final_snapshot       = var.skip_final_snapshot
  final_snapshot_identifier = local.final_snapshot_identifier

  performance_insights_enabled          = var.performance_insights_enabled
  performance_insights_retention_period = var.performance_insights_enabled ? var.performance_insights_retention_period : null
  performance_insights_kms_key_id       = var.performance_insights_enabled ? var.performance_insights_kms_key_id : null

  backup_retention_period = var.backup_retention_period
  backup_window           = var.backup_window
  max_allocated_storage   = var.max_allocated_storage
  monitoring_interval     = var.monitoring_interval
  monitoring_role_arn     = var.monitoring_role_arn

  enabled_cloudwatch_logs_exports = var.enabled_cloudwatch_logs_exports

  deletion_protection      = var.deletion_protection
  delete_automated_backups = var.delete_automated_backups

  tags = var.tags
}

resource "aws_db_parameter_group" "parameter_group" {
  count = var.create_parameter_group ? 1 : 0

  name   = local.parameter_group_name
  family = "${var.engine}${var.engine_version}"

  dynamic "parameter" {
    for_each = var.parameters
    content {
      name         = parameter.value.name
      value        = parameter.value.value
      apply_method = lookup(parameter.value, "apply_method", null)
    }
  }
  tags = var.tags
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_db_option_group" "option_group" {
  count                = var.create_potion_group ? 1 : 0
  name                 = local.option_group_name
  engine_name          = var.engine
  major_engine_version = var.engine_version

  dynamic "option" {
    for_each = var.options
    content {
      option_name                    = option.value.option_name
      port                           = lookup(option.value, "port", null)
      version                        = lookup(option.value, "version", null)
      db_security_group_memberships  = lookup(option.value, "db_security_group_memberships", null)
      vpc_security_group_memberships = lookup(option.value, "vpc_security_group_memberships", null)

      dynamic "option_settings" {
        for_each = lookup(option.value, "option_settings", [])
        content {
          name  = lookup(option_settings.value, "name", null)
          value = lookup(option_settings.value, "value", null)
        }
      }
    }
  }

  tags = var.tags

  timeouts {
    delete = lookup(var.timeouts, "delete", null)
  }

  lifecycle {
    create_before_destroy = true
  }
}