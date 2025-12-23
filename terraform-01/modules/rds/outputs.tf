output "rds_endpoint" {
  value       = aws_db_instance.this.endpoint
  description = "RDS instance endpoint"
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
  value       = var.username
  description = "RDS database master username"
}

output "rds_password" {
  value       = var.password
  description = "RDS database master password"
  sensitive   = true
}

output "client_security_group_id" {
  value       = aws_security_group.client.id
  description = "Security group ID to attach to resources that need database access"
}
