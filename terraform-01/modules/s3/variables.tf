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