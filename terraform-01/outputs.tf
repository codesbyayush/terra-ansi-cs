output "ec2_instance_ids" {
  value       = module.ec2.instance_ids
  description = "EC2 instance IDs"
  sensitive = true
}

output "ec2_public_ips" {
  value       = module.ec2.instance_public_ips
  description = "EC2 instance public IP addresses"
  sensitive = true
}

output "alb_dns_name" {
  value       = module.alb.alb_dns_name
  description = "Application Load Balancer DNS name"
}

output "rds_endpoint" {
  value       = module.rds.rds_endpoint
  description = "RDS PostgreSQL endpoint"
  sensitive = true
}

output "rds_port" {
  value       = module.rds.rds_port
  description = "RDS PostgreSQL port"
}

output "rds_db_name" {
  value       = module.rds.rds_db_name
  description = "RDS database name"
  sensitive = true
}

output "ansible_password" {
  value = module.ec2.ansible_password
  sensitive = true
}

output "rds_username" {
  value       = module.rds.rds_username
  description = "RDS database master username"
  sensitive = true
}

output "rds_password" {
  value       = module.rds.rds_password
  description = "RDS database master password"
  sensitive   = true
}