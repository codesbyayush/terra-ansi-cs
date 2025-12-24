variable "vpc_id" {
  type        = string
  description = "VPC ID for security groups and target group"
}

variable "subnets" {
  type        = set(string)
  description = "Subnet IDs for the load balancer (minimum 2 in different AZs)"

  validation {
    condition     = length(var.subnets) >= 2
    error_message = "ALB requires at least 2 subnets in different availability zones"
  }
}

variable "name_prefix" {
  type        = string
  description = "Name prefix for all resources in this module"

  validation {
    condition     = length(var.name_prefix) >= 1 && length(var.name_prefix) <= 20
    error_message = "name_prefix must be between 1 and 20 characters (ALB/Target Group have 32 char limit)"
  }
}

variable "ingress_rules" {
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
    description = optional(string, "")
  }))
  default = [
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "HTTP"
    }
  ]
  description = "List of ingress rules for the ALB"
}

variable "egress_rules" {
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
    description = optional(string, "")
  }))
  default = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
      description = "Allow all outbound"
    }
  ]
  description = "List of egress rules (defaults to allow all outbound)"
}

variable "internal" {
  type        = bool
  default     = false
  description = "Switch for making alb internal"
}

variable "target_groups" {
  type = map(object({
    port             = number
    protocol         = string
    protocol_version = string
    target_ids       = set(string)
  }))
  description = "Target groups to create for the alb"
}

variable "listeners" {
  type = map(object({
    port     = number
    protocol = string
  }))
  description = "Listeners to create for the ALB. Each listener forwards to a target group specified by map key"
}