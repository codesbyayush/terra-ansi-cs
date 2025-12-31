output "role_name" {
  value       = aws_iam_role.this.name
  description = "Name of the IAM role"
}

output "role_arn" {
  value       = aws_iam_role.this.arn
  description = "ARN of the IAM role"
}

output "role_id" {
  value       = aws_iam_role.this.id
  description = "ID of the IAM role"
}

output "instance_profile_name" {
  value       = var.create_instance_profile ? aws_iam_instance_profile.this[0].name : null
  description = "Name of the IAM instance profile (null if not created)"
}

output "instance_profile_arn" {
  value       = var.create_instance_profile ? aws_iam_instance_profile.this[0].arn : null
  description = "ARN of the IAM instance profile (null if not created)"
}
