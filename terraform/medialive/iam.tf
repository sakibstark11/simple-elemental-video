resource "aws_iam_role" "medialive_iam_role" {
  name               = "${var.prefix}-medialive-role"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.medialive_iam_assume_role.json

  inline_policy {
    name   = "mediaconnect-input"
    policy = data.aws_iam_policy_document.medialive_iam_mediaconnect_policy.json
  }

  inline_policy {
    name   = "logs"
    policy = data.aws_iam_policy_document.medialive_iam_logs_policy.json
  }

  inline_policy {
    name   = "mediapackage"
    policy = data.aws_iam_policy_document.medialive_iam_mediapackage_policy.json
  }
}