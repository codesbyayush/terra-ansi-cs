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