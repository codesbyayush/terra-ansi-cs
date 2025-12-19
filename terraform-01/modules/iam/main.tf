data "aws_iam_policy_document" "state_file_access_policy_document" {
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

resource "aws_iam_group_policy" "state_file_access_policy" {
  name   = "devops_state_file_access_policy"
  policy = data.aws_iam_policy_document.state_file_access_policy_document.json
  group  = aws_iam_group.devops.name
}

resource "aws_iam_group" "devops" {
  name = "devops_eng"
  path = "/devops/"
}