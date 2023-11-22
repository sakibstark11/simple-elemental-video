module "mediaconnect" {
  source = "./mediaconnect"
  prefix                 = var.prefix
  mediaconnect_protocol  = var.mediaconnect_settings.mediaconnect_protocol
  whitelist_cidr_address = var.mediaconnect_settings.whitelist_cidr_address
  ingest_port            = var.mediaconnect_settings.ingest_port
}

module "medialive" {
  source                  = "./medialive"
  prefix                  = var.prefix
  mediaconnect_flow_arn   = module.mediaconnect.flow_arn
  mediapackage_channel_id = module.mediapackage.channel_id
}

module "mediapackage" {
  source = "./mediapackage"
  prefix = var.prefix
}
