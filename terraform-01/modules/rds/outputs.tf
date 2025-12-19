output "rds_endpoint" {
  value       = aws_db_instance.main-db.endpoint
  description = "RDS instance endpoint"
}

output "rds_address" {
  value       = aws_db_instance.main-db.address
  description = "RDS instance address (hostname)"
}

output "rds_port" {
  value       = aws_db_instance.main-db.port
  description = "RDS instance port"
}

output "rds_db_name" {
  value       = aws_db_instance.main-db.db_name
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

