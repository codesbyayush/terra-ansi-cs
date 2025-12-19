variable "env" {
  type        = string
  description = "Instance type like - staging, dev, prod"
}

variable "vpc_id" {
  type = string
  description = "VPC id "
}

variable "ingress_ips" {
  type        = set(string)
  description = "Whitelisted IP's for ingress in our security groups"
}
