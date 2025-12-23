terraform {
  required_version = "1.14.1"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.27.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.7.2"
    }
  }
}

provider "aws" {
  region = var.region

  default_tags {
    tags = {
      Environment       = var.env
      ManagedBy         = "terraform"
      Owner             = "ayush"
      AppName           = var.app_name
      CloudWatchEnabled = "false"
    }
  }
}
