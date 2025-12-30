data "aws_iam_policy_document" "ec2_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "ec2_s3_access" {
  statement {
    sid = "S3BuildFilesAccess"
    actions = [
      "s3:GetObject",
      "s3:ListBucket",
    ]
    resources = [
      var.build_files_bucket_arn,
      "${var.build_files_bucket_arn}/*",
    ]
  }
}

resource "aws_iam_role" "ec2_s3_access" {
  name               = "${var.name_prefix}-ec2-s3-access-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json

  tags = {
    Name = "${var.name_prefix}-ec2-s3-access-role"
  }
}

resource "aws_iam_role_policy" "ec2_s3_access" {
  name   = "${var.name_prefix}-ec2-s3-access-policy"
  role   = aws_iam_role.ec2_s3_access.id
  policy = data.aws_iam_policy_document.ec2_s3_access.json
}

resource "aws_iam_instance_profile" "ec2_s3_access" {
  name = "${var.name_prefix}-ec2-s3-access-profile"
  role = aws_iam_role.ec2_s3_access.name

  tags = {
    Name = "${var.name_prefix}-ec2-s3-access-profile"
  }
}