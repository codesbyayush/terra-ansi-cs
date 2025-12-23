variable "vpc_cidr" {
  type        = string
  description = "VPC network CIDR block"

  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "vpc_cidr must be a valid CIDR block"
  }
}

variable "public_subnet_count" {
  type        = number
  description = "Number of public subnets to create"

  validation {
    condition     = var.public_subnet_count >= 0 && var.public_subnet_count <= 10
    error_message = "public_subnet_count must be between 0 and 10"
  }
}

variable "private_subnet_count" {
  type        = number
  description = "Number of private subnets to create"

  validation {
    condition     = var.private_subnet_count >= 0 && var.private_subnet_count <= 10
    error_message = "private_subnet_count must be between 0 and 10"
  }
}

variable "region" {
  type        = string
  description = "AWS region to create resource in"
}

variable "avl_zones" {
  type        = set(string)
  description = "Set of availability zones to use"

  validation {
    condition     = length(var.avl_zones) >= 1
    error_message = "At least one availability zone must be provided"
  }
}

variable "name_prefix" {
  type        = string
  description = "Name prefix for all resources in this module"
}