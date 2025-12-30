locals {
  name_prefix = "${var.name_prefix}-secret-"
}

resource "aws_secretsmanager_secret" "this" {
  name_prefix             = local.name_prefix
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "this" {
  secret_id                = aws_secretsmanager_secret.this.id
  secret_string_wo         = var.secret_string
  secret_string_wo_version = 1
}