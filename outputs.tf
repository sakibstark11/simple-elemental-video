output "mediaconnect_ingress_ip" {
  value = module.aws_elemental_video_pipeline.mediaconnect_ingress_ip
}

output "mediaconnect_ingest_port" {
  value = module.aws_elemental_video_pipeline.mediaconnect_ingest_port
}

output "mediaconnect_flow_arn" {
  value = module.aws_elemental_video_pipeline.mediaconnect_flow_arn
}

output "medialive_channel_id" {
  value = module.aws_elemental_video_pipeline.medialive_channel_id
}
