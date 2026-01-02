variable "vpc_id" {
  type        = string
  description = "VPC ID where security groups will be created"
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
  description = "Allocated storage in GB. Minimum: 20 for gp2/gp3, 100 for io1/io2"

  validation {
    condition     = var.allocated_storage >= 20 && var.allocated_storage <= 65536
    error_message = "allocated_storage must be between 20 and 65536 GB (note: io1/io2 require minimum 100 GB)"
  }
}

variable "max_allocated_storage" {
  type        = number
  default     = null
  description = "Max storage for autoscaling (set higher than allocated_storage to enable). Set to null to disable."
}

variable "storage_type" {
  type        = string
  default     = "gp3"
  description = "Storage type: gp2, gp3, io1, io2"

  validation {
    condition     = contains(["gp2", "gp3", "io1", "io2"], var.storage_type)
    error_message = "storage_type must be one of: gp2, gp3, io1, io2"
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

variable "parameter_grp_family" {
  type        = string
  description = "Name of the db parameter group family"
}

variable "multi_az" {
  type        = bool
  default     = false
  description = "Enable Multi-AZ deployment for high availability"
}

variable "deletion_protection" {
  type        = bool
  default     = false
  description = "Prevent accidental deletion (must set to false before destroying)"
}

variable "backup_retention_period" {
  type        = number
  default     = 7
  description = "Days to retain automated backups (0 to disable, max 35)"

  validation {
    condition     = var.backup_retention_period >= 0 && var.backup_retention_period <= 35
    error_message = "backup_retention_period must be between 0 and 35"
  }
}

variable "backup_window" {
  type        = string
  default     = null
  description = "Daily backup window in UTC (e.g., '03:00-04:00'). Must not overlap with maintenance_window."
}

variable "maintenance_window" {
  type        = string
  default     = null
  description = "Weekly maintenance window in UTC (e.g., 'Mon:04:00-Mon:05:00')"
}

variable "final_snapshot_identifier" {
  type        = string
  default     = null
  description = "Name of final snapshot when destroying (required if skip_final_snapshot is false)"
}