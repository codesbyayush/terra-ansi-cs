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
  description = "Allow deletion of objects when bucket is deleted (objects are non-recoverable)"
}

variable "versioning_enabled" {
  type        = bool
  default     = false
  description = "Enable versioning on the bucket"
}

variable "encryption" {
  type = object({
    sse_algorithm      = optional(string, "AES256") # AES256 or aws:kms
    kms_key_id         = optional(string, null)
    bucket_key_enabled = optional(bool, true)
  })
  default     = {}
  description = "Server-side encryption configuration. Set to null to disable."

  validation {
    condition = var.encryption == null || (
      var.encryption.sse_algorithm == "AES256" ||
      (var.encryption.sse_algorithm == "aws:kms" && var.encryption.kms_key_id != null)
    )
    error_message = "When using aws:kms, kms_key_id must be provided"
  }
}

variable "lifecycle_rules" {
  type = map(object({
    enabled = bool
    filter = optional(object({
      prefix = optional(string)
      tag = optional(object({
        key   = string
        value = string
      }))
    }))

    expiration = optional(object({
      date                         = optional(string)
      days                         = optional(number)
      expired_object_delete_marker = optional(bool)
    }))

    transitions = optional(list(object({
      date          = optional(string)
      days          = optional(number)
      storage_class = string
    })))

    noncurrent_version_expiration = optional(object({
      days                     = number
      newer_versions_to_retain = optional(number)
    }))

    noncurrent_version_transitions = optional(list(object({
      days                     = number
      newer_versions_to_retain = optional(number)
      storage_class            = string
    })))

    abort_incomplete_multipart_upload_days = optional(number)
  }))
  default     = {}
  description = "Allows defining lifecycle rules for the bucket level"
}

variable "default_retention" {
  type = object({
    mode  = string
    days  = optional(number)
    years = optional(number)
  })
  default = null
  validation {
    condition = var.default_retention == null || (
      var.default_retention.days != null || var.default_retention.years != null
    )
    error_message = "Pass either days or years for retention"
  }

  validation {
    condition = var.default_retention == null || (
      var.default_retention.mode == "GOVERNANCE" || var.default_retention.mode == "COMPLIANCE"
    )
    error_message = "Retention mode must be GOVERNANCE or COMPLIANCE"
  }

  description = "Object lock retention config (requires versioning and object lock enabled at bucket creation)"
}

variable "cors_rules" {
  type = map(object({
    allowed_headers = optional(list(string), ["*"])
    allowed_methods = list(string)
    allowed_origins = list(string)
    expose_headers  = optional(list(string), [])
    max_age_seconds = optional(number, 3600)
  }))
  default     = {}
  description = "CORS rules for the bucket"
}

variable "logging" {
  type = object({
    target_bucket = string
    target_prefix = optional(string, "")
  })
  default     = null
  description = "Access logging configuration"
}

variable "bucket_policy" {
  type        = string
  default     = null
  description = "Bucket policy JSON document"
}
