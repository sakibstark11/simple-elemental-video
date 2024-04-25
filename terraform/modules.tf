module "mediaconnect" {
  source                 = "./mediaconnect"
  prefix                 = var.prefix
  mediaconnect_protocol  = var.mediaconnect_settings.mediaconnect_protocol
  whitelist_cidr_address = var.mediaconnect_settings.whitelist_cidr_address
  ingest_port            = var.mediaconnect_settings.ingest_port
}

module "medialive" {
  source                = "./medialive"
  prefix                = var.prefix
  mediaconnect_flow_arn = module.mediaconnect.flow_arn
  lambda_url            = module.segment_modifier_lambda.lambda_url
}

module "mediapackage" {
  source = "./mediapackage"
  prefix = var.prefix
}

module "segment_modifier_lambda" {
  source                            = "./segment_modifier_lambda"
  prefix                            = var.prefix
  source_s3_bucket                  = "s3://test"
  mediapackage_hls_ingest_endpoints = module.mediapackage.hls_ingest_endpoints
}
