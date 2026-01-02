output "client_security_group_id" {
  value       = aws_security_group.client.id
  description = "Security group ID to attach to resources that need database access"
}
