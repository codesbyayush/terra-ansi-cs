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

variable "instance_type" {
  type        = string
  default     = "t3a.micro"
  description = "Instance type to provision (defaults to t3a.micro)"
}

variable "cpu_credits_type" {
  type        = string
  default     = "standard"
  description = "Credits type for burstable family instance. (e.g standard or unlimited)"
}

variable "iam_instance_profile" {
  type        = string
  default     = null
  description = "IAM instance profile name to attach to EC2 instances"
}

variable "root_volume" {
  type = object({
    size                  = optional(number, 10)
    type                  = optional(string, "gp3")
    iops                  = optional(number, 3000)
    throughput            = optional(number, 125)
    encrypted             = optional(bool, true)
    kms_key_id            = optional(string, null)
    delete_on_termination = optional(bool, true)
  })
  default     = {}
  description = "Root volume configuration. Size in GB. Type can be gp2, gp3, io1, io2"
}

variable "ebs_volumes" {
  type = list(object({
    device_name           = string
    size                  = number
    type                  = optional(string, "gp3")
    iops                  = optional(number, null)
    throughput            = optional(number, null)
    encrypted             = optional(bool, true)
    kms_key_id            = optional(string, null)
    delete_on_termination = optional(bool, true)
    snapshot_id           = optional(string, null)
  }))
  default     = []
  description = "List of additional EBS volumes to attach. Device names like xvdbb"
}