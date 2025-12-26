variable "env" {
  default     = "dev"
  type        = string
  description = "Instance type like - staging, dev, prod"

  validation {
    condition     = contains(["dev", "staging", "prod", "test"], var.env)
    error_message = "Environment type should be one of the defined values - [dev, staging, prod, test]"
  }
}

variable "josh_ips" {
  default     = ["0.0.0.0/0"]
  type        = set(string)
  description = "Whitelisted IP's for ingress in our security groups"

  validation {
    condition     = alltrue([for ip in var.josh_ips : can(cidrhost(ip, 0))])
    error_message = "All values must be valid CIDR blocks"
  }
}

variable "region" {
  default     = "us-east-1"
  type        = string
  description = "AWS Region to deploy resources in"
}

variable "state_file_bucket" {
  type        = string
  description = "The S3 bucket storing the state file"
}

variable "db_name" {
  type        = string
  description = "Name of the database to create"
}

variable "app_name" {
  type        = string
  default     = "dotnetapi"
  description = "Application or project name"
}

variable "ec2_key_name" {
  type        = string
  description = "Name of the aws key pair for EC2 instances"
}