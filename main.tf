locals {
  prefix = "sakib"
}

data "http" "current_ip" {
  url = "https://api.ipify.org"
}

module "simple_elemental_video_mediaconnect" {
  source                 = "./mediaconnect"
  prefix                 = local.prefix
  whitelist_cidr_address = "${data.http.current_ip.response_body}/32"
}

module "simple_elemental_video_medialive_input" {
  source                  = "./medialive"
  prefix                  = local.prefix
  ingress_flow_arn        = module.simple_elemental_video_mediaconnect.flow_arn
  mediapackage_channel_id = "test"
}
