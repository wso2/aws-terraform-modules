output "id" {
  value = aws_db_proxy_target.target_group.id
}
output "port" {
  value = aws_db_proxy_target.target_group.port
}
output "endpoint" {
  value = aws_db_proxy_target.target_group.endpoint
}
output "target_arn" {
  value = aws_db_proxy_target.target_group.target_arn
}
output "target_group_name" {
  value = aws_db_proxy_target.target_group.target_group_name
}
output "tracked_cluster_id" {
  value = aws_db_proxy_target.target_group.tracked_cluster_id
}
output "name" {
  value = aws_db_proxy_target.target_group.type
}