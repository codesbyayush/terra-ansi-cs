variable "vpc_id" {
  type        = string
  description = "VPC ID where security groups will be created"
}

variable "subnets" {
  type        = list(string)
  description = "List of subnet IDs where instances will be launched"

  validation {
    condition     = length(var.subnets) >= 1
    error_message = "At least one subnet ID must be provided"
  }
}

variable "instance_tags" {
  type        = map(string)
  default     = {}
  description = "Additional tags specific to EC2 instances"
}

variable "name_prefix" {
  type        = string
  description = "Name prefix for all resources in this module"
}

variable "key_name" {
  type        = string
  description = "Name of the SSH key pair to use for the instance"
}

variable "user_data" {
  type        = string
  description = "User data script to run on instance launch"
  default     = null
}

variable "enable_ssh" {
  type        = bool
  default     = false
  description = "Enable SSH (port 22) from dev_access_cidrs"
}

variable "enable_rdp" {
  type        = bool
  default     = false
  description = "Enable RDP (port 3389) from dev_access_cidrs"
}

variable "dev_access_cidrs" {
  type        = list(string)
  default     = []
  description = "CIDR blocks for dev access (SSH, RDP)"
}

variable "ingress_rules" {
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
    description = optional(string, "")
  }))
  default     = []
  description = "List of custom ingress rules"
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

variable "additional_sg_ids" {
  type        = list(string)
  default     = []
  description = "Additional security group IDs to attach (e.g., RDS client SG)"
}
