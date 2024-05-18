data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy_document" "lambda_logs_policy" {
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
    actions   = ["s3:GetObject"]
    effect    = "Allow"
    resources = ["arn:aws:s3:::${var.source_s3_bucket}/*"]
  }
}

resource "aws_iam_role" "lambda_iam_role" {
  name               = "${var.prefix}-lambda-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
  inline_policy {
    name   = "s3"
    policy = data.aws_iam_policy_document.s3_policy.json
  }
  inline_policy {
    name   = "logs"
    policy = data.aws_iam_policy_document.lambda_logs_policy.json
  }
}

resource "aws_lambda_function" "segment_modifier" {
  function_name = "${var.prefix}-segment-modifier"
  role          = aws_iam_role.lambda_iam_role.arn
  image_uri     = docker_registry_image.container_image.name
  timeout       = 30
  memory_size   = 1024
  package_type  = "Image"
  environment {
    variables = {
      mediapackage_hls_ingest_endpoints = jsonencode(var.mediapackage_hls_ingest_endpoints)
    }
  }
}

resource "aws_lambda_permission" "s3_invoke" {
  statement_id  = "AllowS3Invoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.segment_modifier.arn
  principal     = "s3.amazonaws.com"
  source_arn    = "arn:aws:s3:::${var.source_s3_bucket}"
}
