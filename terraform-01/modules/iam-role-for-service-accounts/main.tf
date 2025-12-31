locals {
  assume_role_policy = var.assume_role_policy != null ? var.assume_role_policy : data.aws_iam_policy_document.assume_role[0].json
}

data "aws_iam_policy_document" "assume_role" {
  count = var.assume_role_policy == null ? 1 : 0

  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = var.trusted_services
    }
  }
}

resource "aws_iam_role" "this" {
  name               = "${var.name_prefix}-${var.role_name}"
  assume_role_policy = local.assume_role_policy

  tags = merge(
    {
      Name = "${var.name_prefix}-${var.role_name}"
    },
    var.tags
  )
}

resource "aws_iam_role_policy" "this" {
  for_each = var.policies

  name   = "${var.name_prefix}-${each.key}"
  role   = aws_iam_role.this.id
  policy = each.value.policy_json
}

resource "aws_iam_instance_profile" "this" {
  count = var.create_instance_profile ? 1 : 0

  name = "${var.name_prefix}-${var.role_name}-profile"
  role = aws_iam_role.this.name

  tags = merge(
    {
      Name = "${var.name_prefix}-${var.role_name}-profile"
    },
    var.tags
  )
}