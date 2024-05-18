resource "aws_iam_role" "medialive_iam_role" {
  name               = "${var.prefix}-medialive-role"
  assume_role_policy = data.aws_iam_policy_document.medialive_iam_assume_role.json

  inline_policy {
    name   = "mediaconnect"
    policy = data.aws_iam_policy_document.medialive_iam_mediaconnect_policy.json
  }

  inline_policy {
    name   = "logs"
    policy = data.aws_iam_policy_document.medialive_iam_logs_policy.json
  }

  inline_policy {
    name   = "s3"
    policy = data.aws_iam_policy_document.s3_policy.json
  }
}
