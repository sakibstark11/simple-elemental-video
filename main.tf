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

  mediaconnect_settings = {
    mediaconnect_protocol  = "srt-listener"
    whitelist_cidr_address = "${data.http.current_ip.response_body}/32"
    ingest_port            = 5000
  }
}
