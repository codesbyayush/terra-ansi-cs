data "aws_iam_policy_document" "this" {
  statement {
    sid = "GetObjects"
    actions = [
      "s3:GetObject",
    ]

    resources = [
      "arn:aws:s3:::${var.state_file_bucket}/*",
    ]
  }
}

resource "aws_iam_group_policy" "this" {
  name   = "devops_state_file_access_policy"
  policy = data.aws_iam_policy_document.this.json
  group  = aws_iam_group.this.name
}

resource "aws_iam_group" "this" {
  name = "devops_eng"
  path = "/devops/"
}
