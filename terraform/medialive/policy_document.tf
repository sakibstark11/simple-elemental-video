data "aws_iam_policy_document" "medialive_iam_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["medialive.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "medialive_iam_mediaconnect_policy" {
  statement {
    actions = [
      "mediaconnect:ManagedDescribeFlow",
      "mediaconnect:ManagedAddOutput",
      "mediaconnect:ManagedRemoveOutput"
    ]
    effect    = "Allow"
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "medialive_iam_logs_policy" {
  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogStreams",
      "logs:DescribeLogGroups"
    ]
    effect    = "Allow"
    resources = ["arn:aws:logs:*:*:*"]
  }
}

data "aws_iam_policy_document" "s3_policy" {
  statement {
    actions   = ["s3:PutObject"]
    effect    = "Allow"
    resources = ["arn:aws:s3:::${var.segment_storage_bucket}/*"]
  }
}
