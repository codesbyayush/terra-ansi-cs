output "dev_access" {
  value = aws_security_group.enable_dev_access.id
}

output "http_access" {
  value = aws_security_group.enable_http.id
}

output "outbound_access" {
  value = aws_security_group.enable_outbound.id
}

output "rds_client" {
  value = aws_security_group.rds_client.id
}

output "rds_server" {
  value = aws_security_group.rds_server.id
}