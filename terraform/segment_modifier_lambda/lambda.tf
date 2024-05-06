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

# data "archive_file" "lambda_zip" {
#   type        = "zip"
#   source_dir  = "${path.module}/lambda"
#   output_path = "${path.module}/lambda.zip"
#   excludes = concat(
#     [
#       "${path.module}/lambda.zip",
#       "${path.module}/layer.zip"
#     ],
#     tolist(fileset("${path.module}/layer", "**"))
#   )
# }

# resource "null_resource" "python_requirements" {
#   triggers = {
#     requirements_md5 = filemd5("${path.module}/lambda/requirements.txt")
#   }
#   provisioner "local-exec" {
#     when    = create
#     command = "pip install -r ${path.module}/lambda/requirements.txt -t ${path.module}/layer/python --force-reinstall -vvv"
#   }
# }

# data "archive_file" "layer_zip" {
#   type        = "zip"
#   source_dir  = "${path.module}/layer/"
#   output_path = "${path.module}/layer.zip"
#   excludes = concat(
#     tolist(fileset("${path.module}", "*.tf")),
#     tolist(fileset("${path.module}/lambda", "**")),
#     [
#       "${path.module}/layer.zip",
#       "${path.module}/lambda.zip"
#     ]
#   )
#   depends_on = [null_resource.python_requirements]
# }

# resource "aws_s3_bucket" "layer_bucket" {
#   bucket        = "${var.prefix}-layer"
#   force_destroy = true
# }

# resource "aws_s3_object" "layer_upload" {
#   bucket = aws_s3_bucket.layer_bucket.id
#   key    = "layer.zip"
#   source = data.archive_file.layer_zip.output_path
# }

# resource "aws_lambda_layer_version" "python_requirements_layer" {
#   layer_name          = "${var.prefix}-python-layer"
#   source_code_hash    = data.archive_file.layer_zip.output_base64sha256
#   compatible_runtimes = ["python3.11"]
#   s3_bucket           = aws_s3_bucket.layer_bucket.id
#   s3_key              = aws_s3_object.layer_upload.key
# }


resource "aws_lambda_function" "segment_modifier" {
  function_name = "${var.prefix}-segment-modifier"
  role          = aws_iam_role.lambda_iam_role.arn
  runtime       = "python3.11"
  image_uri     = docker_registry_image.container_image.name
  timeout       = 30
  memory_size   = 1024
  package_type  = "Image"
  environment {
    variables = {
      mediapackage_hls_ingest_endpoints = jsonencode(var.mediapackage_hls_ingest_endpoints)
    }
  }
  depends_on = []
}

resource "aws_lambda_permission" "s3_invoke" {
  statement_id  = "AllowS3Invoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.segment_modifier.arn
  principal     = "s3.amazonaws.com"
  source_arn    = "arn:aws:s3:::${var.source_s3_bucket}"
}
