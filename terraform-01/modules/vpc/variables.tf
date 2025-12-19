variable "env" {
  type        = string
  description = "Instance type like - staging, dev, prod"
}

variable "vpc_cidr" {
  type        = string
  description = "Vpc network CIDR"
}

variable "public_subnet_count" {
  type        = number
  description = "Number of required subnets"
}

variable "private_subnet_count" {
  type        = number
  description = "Number of required subnets"
}

variable "region" {
  type = string
  description = "AWS region to create resource in"
}

variable "avl_zones" {
  type = set(string)
}