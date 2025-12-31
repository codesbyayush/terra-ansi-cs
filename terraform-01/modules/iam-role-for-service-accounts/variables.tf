variable "name_prefix" {
  type        = string
  description = "Name prefix for all resources in this module"
}

variable "role_name" {
  type        = string
  description = "Name of the IAM role"
}

variable "trusted_services" {
  type        = list(string)
  description = "List of AWS services that can assume this role (e.g., ['ec2.amazonaws.com', 'lambda.amazonaws.com'])"
  default     = []
}

variable "assume_role_policy" {
  type        = string
  description = "Custom assume role policy JSON (overrides trusted_services if provided)"
  default     = null
}

variable "policies" {
  type = map(object({
    policy_json = string
  }))
  description = "Map of policy name to policy JSON content"
  default     = {}
}

variable "create_instance_profile" {
  type        = bool
  description = "Flag for whether to create an instance profile for this role"
  default     = false
}

variable "tags" {
  type        = map(string)
  description = "Additional tags for resources"
  default     = {}
}
