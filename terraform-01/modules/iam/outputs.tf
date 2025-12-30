output "ec2_instance_profile_name" {
  value       = aws_iam_instance_profile.ec2_s3_access.name
  description = "Name of the IAM instance profile for EC2 S3 access"
}

output "ec2_role_arn" {
  value       = aws_iam_role.ec2_s3_access.arn
  description = "ARN of the IAM role for EC2 S3 access"
}

