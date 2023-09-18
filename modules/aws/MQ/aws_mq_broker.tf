resource "aws_mq_broker" "mq" {
  broker_name = join("-", [var.project, var.application, var.environment, var.region, "mq"])

  engine_type = "ActiveMQ"
  engine_version = var.engine_version
  host_instance_type = var.instance_type
  security_groups = var.security_group_ids
  subnet_ids = var.subnet_ids
  publicly_accessible = var.public_access
  auto_minor_version_upgrade = var.auto_minor_version_upgrade

  dynamic "user" {
    for_each = var.users
    content {
      username = user.value.username
      password = user.value.password
      console_access = user.value.console_access
    }
  }

  logs {
    audit = var.audit_logs_enabled
    general = var.general_logs_enabled
  }
}
