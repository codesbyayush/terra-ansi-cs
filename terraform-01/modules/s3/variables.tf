variable "region" {
  type = string
}

variable "name_prefix" {
  type = string
  validation {
    condition     = length(var.name_prefix) >= 3 && length(var.name_prefix) <= 37
    error_message = "Max length of name prefix is capped by terraform"
  }
}

variable "force_destroy" {
  type        = bool
  default     = true
  description = "Allow deletion of objects when bucket is deleted otherwise will throw error. (Objects once deleted are non-recoverable)"
}

variable "lifecycle_rules" {
  type = map(object({
    enabled = bool
    expiration = object({
      date = optional(string)
      days = optional(number)
    })
  }))
  default     = {}
  description = "Allows defining lifecycle rules for the bucket level"
}

variable "versioning_enabled" {
  type    = bool
  default = false
}

variable "default_retention" {
  type = object({
    mode  = string
    days  = optional(number)
    years = optional(number)
  })
  default = null
  validation {
    condition = var.default_retention == null || (try(var.default_retention.days, null) != null ||
    try(var.default_retention.years, null) != null)
    error_message = "Pass either years or days for retention"
  }
  validation {
    condition     = var.default_retention == null || var.versioning_enabled == true
    error_message = "Object lock requires versioning to be enabled in the bucket"
  }
  description = "Object retention config. (Auto enables object lock)"
}