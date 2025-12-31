locals {
  name_prefix = "${var.name_prefix}-s3"
}

resource "aws_s3_bucket" "this" {
  bucket_prefix = local.name_prefix
  region        = var.region
  force_destroy = var.force_destroy

  tags = {
    Name = local.name_prefix
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "this" {
  for_each = var.lifecycle_rules
  bucket   = aws_s3_bucket.this.id

  rule {
    id     = each.key
    status = each.value.enabled ? "Enabled" : "Disabled"

    dynamic "expiration" {
      for_each = try([each.value.expiration], [])
      content {
        date = try(expiration.value.date, null)
        days = try(expiration.value.days, null)
      }
    }
  }
}

resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this.id

  versioning_configuration {
    status = var.versioning_enabled ? "Enabled" : "Disabled"
  }
}

resource "aws_s3_bucket_object_lock_configuration" "this" {
  count  = var.default_retention != null ? 1 : 0
  bucket = aws_s3_bucket.this.id

  rule {
    default_retention {
      mode  = var.default_retention.mode
      days  = var.default_retention.days
      years = var.default_retention.years
    }
  }
}