resource "aws_s3_bucket" "segment_storage" {
  bucket        = "${var.prefix}-segment-storage"
  force_destroy = true
}

resource "aws_s3_bucket" "segment_server" {
  bucket        = "${var.prefix}-segment-server"
  force_destroy = true
}

resource "aws_s3_bucket_public_access_block" "segment_server" {
  bucket = aws_s3_bucket.segment_server.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_website_configuration" "server" {
  bucket = aws_s3_bucket.segment_server.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

resource "aws_s3_bucket_policy" "allow_access_from_web" {
  bucket = aws_s3_bucket.segment_server.id
  policy = data.aws_iam_policy_document.allow_access_from_web.json
}

data "aws_iam_policy_document" "allow_access_from_web" {
  statement {
    actions = [
      "s3:GetObject",
    ]
    effect = "Allow"
    principals {
      type        = "*"
      identifiers = ["*"]
    }
    resources = [
      "${aws_s3_bucket.segment_server.arn}/*",
    ]
  }
}

resource "aws_s3_bucket_notification" "segment_storage" {
  bucket = aws_s3_bucket.segment_storage.id
  lambda_function {
    filter_suffix       = ".ts"
    lambda_function_arn = module.segment_modifier_lambda.lambda_arn
    events              = ["s3:ObjectCreated:*"]
  }

  lambda_function {
    filter_suffix       = ".m3u8"
    lambda_function_arn = module.segment_modifier_lambda.lambda_arn
    events              = ["s3:ObjectCreated:*"]
  }
}
