locals {
  prefix = "a_prefix"
}

data "http" "current_ip" {
  url = "https://api.ipify.org/"
}

module "simple_elemental_video_mediaconnect" {
  source                 = "./mediaconnect"
  prefix                 = local.prefix
  whitelist_cidr_address = data.http.current_ip.request_body
}
