output "vpc_id" {
  value       = aws_vpc.this.id
  description = "ID of the created VPC"
}

output "public_subnets" {
  value       = aws_subnet.public
  description = "List of public subnet resources with their attributes"
}

output "private_subnets" {
  value       = aws_subnet.private
  description = "List of private subnet resources with their attributes"
}
