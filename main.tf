# FIXME: s3 backend or local?
#terraform {
#  backend "s3" {}
#  required_providers {
#    aws = {
#      source  = "hashicorp/aws"
#      version = "~> 4.0"
#    }
#  }
#}

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

module "orchestrator" {
  source = "./terraform"
  prefix = "simple-eml"
  aws_profile = "my-profile"
  mediaconnect_settings = {
    mediaconnect_protocol = "srt-listener"
    whitelist_cidr_address = ["${data.http.current_ip.response_body}/32"]
    ingress_port = 5000
  }
}
