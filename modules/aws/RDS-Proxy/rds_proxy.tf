locals {
  identifier = lower(join("-", [var.project, var.application, var.environment, var.region, var.engine, "db-proxy"]))
}

resource "aws_db_proxy" "db_proxy" {
  name                   = local.identifier
  debug_logging          = false
  engine_family          = var.engine
  idle_client_timeout    = 1800
  require_tls            = var.require_tls
  role_arn               = var.role_arn
  vpc_security_group_ids = var.vpc_security_group_ids
  vpc_subnet_ids         = var.vpc_subnets

  dynamic "auth" {
    for_each = var.auth_list

    content {
      auth_scheme               = auth.value["auth_scheme"]
      iam_auth                  = auth.value["iam_auth"]
      client_password_auth_type = auth.value["client_password_auth_type"]
      secret_arn                = auth.value["secret_arn"]
      username                  = auth.value["username"]
      description               = auth.value["description"]
    }
  }

  tags = var.tags
}

resource "aws_db_proxy_default_target_group" "default_target_group" {
  db_proxy_name = aws_db_proxy.db_proxy.name
}