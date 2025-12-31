output "ec2_public_ips" {
  value       = module.ec2.instance_public_ips
  description = "EC2 instance public IP addresses"
  sensitive   = true
}

output "alb_dns_name" {
  value       = module.alb.alb_dns_name
  description = "Application Load Balancer DNS name"
}

output "build_files_bucket_name" {
  value       = module.s3_build_files.bucket_name
  description = "S3 bucket name for build files"
}