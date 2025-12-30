variable "state_file_bucket" {
  type        = string
  description = "The S3 bucket storing the state file"
}

variable "build_files_bucket_arn" {
  type        = string
  description = "ARN of the S3 bucket containing build files"
}

variable "name_prefix" {
  type        = string
  description = "Name prefix for all resources in this module"
}