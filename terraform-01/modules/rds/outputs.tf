output "rds_address" {
  value       = aws_db_instance.this.address
  description = "RDS instance dns name address"
}

output "rds_port" {
  value       = aws_db_instance.this.port
  description = "RDS instance port"
}

output "rds_db_name" {
  value       = aws_db_instance.this.db_name
  description = "RDS database name"
}

output "rds_username" {
  value       = random_string.db_username.result
  description = "RDS database master username"
}

output "rds_password" {
  value       = random_password.db_password.result
  description = "RDS database master password"
  sensitive   = true
}

output "client_security_group_id" {
  value       = aws_security_group.client.id
  description = "Security group ID to attach to resources that need database access"
}
