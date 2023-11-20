module "simple_elemental_video_mediaconnect" {
  source                 = "./mediaconnect"

  prefix                 = var.prefix
  mediaconnect_protocol = var.mediaconnect_settings.mediaconnect_protocol
  whitelist_cidr_address = var.mediaconnect_settings.whitelist_cidr_address
  ingress_port = var.mediaconnect_settings.ingress_port
}

module "simple_elemental_video_medialive" {
  source           = "./medialive"
  prefix           = var.prefix
  ingress_flow_arn = module.simple_elemental_video_mediaconnect.flow_arn
}

module "simple_elemental_video_mediapackage" {
  source           = "./mediapackage"
  prefix           = var.prefix
}
