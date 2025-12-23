output "instance_ids" {
  value       = toset([for server in aws_instance.this : server.id])
  description = "Set of EC2 instance IDs"
}

output "instance_public_ips" {
  value       = [for server in aws_instance.this : server.public_ip]
  description = "List of public IP addresses assigned to the instances"
}
