variable "env" {
  type = string
}

variable "username" {
  type = string
}

variable "password" {
  type = string
}

variable "engine" {
  type = string
}

variable "instance_class" {
  type = string
}

variable "engine_version" {
  type = string
}

variable "allocated_storage" {
  type    = number
  default = 20
}

variable "subnet_ids" {
  type = set(string)
}

variable "encrypt_storage" {
  type = bool
}

variable "apply_immediately" {
  type = bool
}

variable "skip_final_snapshot" {
  type = bool
}

variable "db_name" {
  type        = string
  description = "Name of the database to create"
}

variable "vpc_security_group_ids" {
  type        = list(string)
  description = "List of VPC security group IDs to attach to RDS instance"
}