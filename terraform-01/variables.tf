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
}

variable "region" {
  default     = "us-east-1"
  type        = string
  description = "AWS Region to deploy resources in"
}

variable "state_file_bucket" {
  type = string
  description = "The S3 bucket storing the state file"
}

variable "username" { 
  type        = string
  default     = null
  description = "DB username (if not provided, will be auto-generated)"
}

variable "password" {
   type        = string
   default     = null
   description = "DB master password (if not provided, will be auto-generated)"
}

variable "db_name" {
  type = string
}