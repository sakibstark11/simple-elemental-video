terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

data "http" "current_ip" {
  url = "https://api.ipify.org"
}

module "aws_elemental_video_pipeline" {
  source      = "./terraform"
  prefix      = "simple-elemental"
  aws_profile = "bot"
  mediaconnect_settings = {
    mediaconnect_protocol  = "srt-listener"
    whitelist_cidr_address = "${data.http.current_ip.response_body}/32"
    ingest_port            = 5000
  }
}


output "mediaconnect_ingress_ip" {
  value = module.aws_elemental_video_pipeline.mediaconnect_ingress_ip
}

output "mediaconnect_ingest_port" {
  value = module.aws_elemental_video_pipeline.mediaconnect_ingest_port
}

output "mediapackage_hls_endpoint" {
  value = module.aws_elemental_video_pipeline.mediapackage_hls_endpoint
}

output "mediaconnect_flow_arn" {
  value = module.aws_elemental_video_pipeline.mediaconnect_flow_arn
}

output "medialive_channel_id" {
  value = module.aws_elemental_video_pipeline.medialive_channel_id
}

output "mediapackage_channel_id" {
  value = module.aws_elemental_video_pipeline.mediapackage_channel_id
}
