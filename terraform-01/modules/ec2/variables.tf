

variable "env" {
  type        = string
  description = "Instance type like - staging, dev, prod"
}

variable "sg_ids" {
    type = set(string)
}

variable "subnets" {
  type = list(string)
}