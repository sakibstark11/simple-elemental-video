resource "aws_s3_bucket" "segment_storage" {
  bucket = "${var.prefix}-segment-storage"
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
