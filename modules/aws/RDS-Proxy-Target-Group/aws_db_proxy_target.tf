resource "aws_db_proxy_target" "target_group" {
  db_instance_identifier = lower(var.db_instance_identifier)
  db_cluster_identifier  = var.db_cluster_identifier
  db_proxy_name          = var.db_proxy_name
  target_group_name      = var.default_target_group_name
}