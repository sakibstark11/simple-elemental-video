output "mediaconnect_ingress_ip" {
  value = module.mediaconnect.ingress_ip
}

output "mediaconnect_ingest_port" {
  value = module.mediaconnect.ingest_port
}

output "mediaconnect_flow_arn" {
  value = module.mediaconnect.flow_arn
}

output "medialive_channel_id" {
  value = module.medialive.channel_id
}

output "mediapackage_hls_endpoint" {
  value = module.mediapackage.hls_origin_endpoint
}
