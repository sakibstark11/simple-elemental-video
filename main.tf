terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.45.0"
    }
  }
}

data "http" "current_ip" {
  url = "https://api.ipify.org"
}

variable "prefix" {
  type        = string
  description = "to use for grouping resources"
  default     = "simple-elemental-video"
}

module "aws_elemental_video_pipeline" {
  source = "./terraform"
  prefix = var.prefix

  mediaconnect_settings = {
    mediaconnect_protocol  = "srt-listener"
    whitelist_cidr_address = "${data.http.current_ip.response_body}/32"
    ingest_port            = 5000
  }
}
