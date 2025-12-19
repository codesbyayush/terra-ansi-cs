variable "subnets" {
  type = set(string)
}

variable "sg_ids" {
  type = set(string)
}

variable "env" {
  type = string
}

variable "vpc_id" {
  type        = string
  description = "VPC id "
}

variable "target_ids" {
  type        = set(string)
  description = "Target group ids to load balance"
}
