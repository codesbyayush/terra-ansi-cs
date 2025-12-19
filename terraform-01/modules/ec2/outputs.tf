output "instance_ids" {
  value = toset([for server in aws_instance.windows_server : server.id])
}

output "instance_public_ips" {
  value = [for server in aws_instance.windows_server : server.public_ip]
}

output "ansible_password" {
  value = random_password.ansible_password.result
}