output "db_identifier" {
  description = "Identifier of the RDS instance"
  value       = aws_db_instance.database.identifier
}

output "db_instance_address" {
  description = "The address of the RDS instance"
  value       = aws_db_instance.database.address
}

output "db_instance_arn" {
  description = "The ARN of the RDS instance"
  value       = aws_db_instance.database.arn
}

output "db_instance_endpoint" {
  description = "The connection endpoint"
  value       = aws_db_instance.database.endpoint
}


output "db_instance_hosted_zone_id" {
  description = "The canonical hosted zone ID of the DB instance (to be used in a Route 53 Alias record)"
  value       = aws_db_instance.database.hosted_zone_id
}

output "db_instance_id" {
  description = "The RDS instance ID"
  value       = aws_db_instance.database.id
}

output "db_root_id" {
  description = "The RDS manged secret key"
  value       = aws_db_instance.database.master_user_secret[0].secret_arn
}
