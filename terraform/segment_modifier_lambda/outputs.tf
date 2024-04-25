output "lambda_arn" {
  value = aws_lambda_function.segment_modifier.arn
}

output "lambda_url" {
  value = aws_lambda_function_url.segment_modifier.function_url
}
