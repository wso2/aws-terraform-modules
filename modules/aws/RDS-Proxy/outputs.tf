output "db_proxy_name" {
  value = aws_db_proxy.db_proxy.name
}
output "db_proxy_arn" {
  value = aws_db_proxy.db_proxy.arn
}
output "db_proxy_id" {
  value = aws_db_proxy.db_proxy.id
}
output "db_proxy_endpoint" {
  value = aws_db_proxy.db_proxy.endpoint
}

output "default_target_group_arn" {
  value = aws_db_proxy_default_target_group.default_target_group.arn
}
output "default_target_group_id" {
  value = aws_db_proxy_default_target_group.default_target_group.id
}
output "default_target_group_name" {
  value = aws_db_proxy_default_target_group.default_target_group.name
}