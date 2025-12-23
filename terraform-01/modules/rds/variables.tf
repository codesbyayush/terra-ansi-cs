variable "vpc_id" {
  type        = string
  description = "VPC ID where security groups will be created"
}

variable "username" {
  type        = string
  description = "Master username for the database"
}

variable "password" {
  type        = string
  sensitive   = true
  description = "Master password for the database"

  validation {
    condition     = length(var.password) >= 8 && length(var.password) <= 128
    error_message = "Password must be between 8 and 128 characters"
  }
}

variable "engine" {
  type        = string
  description = "Database engine type"
}

variable "instance_class" {
  type        = string
  description = "RDS instance class"
}

variable "engine_version" {
  type        = string
  description = "Database engine version"

  validation {
    condition     = length(var.engine_version) >= 1
    error_message = "engine_version must not be empty"
  }
}

variable "allocated_storage" {
  type        = number
  default     = 20
  description = "Allocated storage in GB"

  validation {
    condition     = var.allocated_storage >= 1 && var.allocated_storage <= 65000
    error_message = "allocated_storage must be between 1 and 65000 GB"
  }
}

variable "subnet_ids" {
  type        = set(string)
  description = "Subnet IDs for the DB subnet group (minimum 2 in different AZs)"

  validation {
    condition     = length(var.subnet_ids) >= 2
    error_message = "RDS subnet group requires at least 2 subnets in different availability zones"
  }
}

variable "encrypt_storage" {
  type        = bool
  description = "Enable storage encryption"
}

variable "apply_immediately" {
  type        = bool
  description = "Apply changes immediately or during maintenance window"
}

variable "skip_final_snapshot" {
  type        = bool
  description = "Skip final snapshot when destroying the database"
}

variable "db_name" {
  type        = string
  description = "Name of the database to create"
}

variable "db_port" {
  type        = number
  default     = 5432
  description = "Database port"
}

variable "name_prefix" {
  type        = string
  description = "Name prefix for all resources in this module"

  validation {
    condition     = length(var.name_prefix) >= 1 && length(var.name_prefix) <= 50
    error_message = "name_prefix must be between 1 and 50 characters (RDS identifier has 63 char limit)"
  }
}
