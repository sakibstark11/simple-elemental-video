output "ingress_ip" {
  value = aws_cloudformation_stack.mediaconnect.outputs.IngressIp
}

output "ingest_port" {
  value = local.cloudformation_resources.Mediaconnect.Properties.Source.IngestPort
}

output "flow_arn" {
  value = aws_cloudformation_stack.mediaconnect.outputs.IngressArn
}
