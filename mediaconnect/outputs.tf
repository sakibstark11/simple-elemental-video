output "ingress_destination" {
  value       = "srt://${aws_cloudformation_stack.mediaconnect.outputs.IngressIp}:${local.cloudformation_resources.Mediaconnect.Properties.Source.IngestPort}"
  description = "destination address"
}

output "flow_arn" {
  value = aws_cloudformation_stack.mediaconnect.outputs.IngressArn
}
