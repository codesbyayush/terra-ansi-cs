output "instance_ids" {
  value       = toset([for server in aws_instance.this : server.id])
  description = "Set of EC2 instance IDs"
}

output "instance_public_ips" {
  value       = [for server in aws_instance.this : server.public_ip]
  description = "List of public IP addresses assigned to the instances"
}

output "root_volume_ids" {
  value       = [for server in aws_instance.this : server.root_block_device[0].volume_id]
  description = "List of root volume IDs for each instance"
}

output "ebs_volume_ids" {
  value = {
    for idx, server in aws_instance.this : server.id => [
      for ebs in server.ebs_block_device : ebs.volume_id
    ]
  }
  description = "Map of instance ID to list of attached EBS volume IDs"
}