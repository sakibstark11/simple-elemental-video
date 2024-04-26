module "mediaconnect" {
  source                 = "./mediaconnect"
  prefix                 = var.prefix
  mediaconnect_protocol  = var.mediaconnect_settings.mediaconnect_protocol
  whitelist_cidr_address = var.mediaconnect_settings.whitelist_cidr_address
  ingest_port            = var.mediaconnect_settings.ingest_port
}

module "medialive" {
  source                 = "./medialive"
  prefix                 = var.prefix
  mediaconnect_flow_arn  = module.mediaconnect.flow_arn
  segment_storage_bucket = aws_s3_bucket.segment_storage.id
}

module "segment_modifier_lambda" {
  source                = "./segment_modifier_lambda"
  prefix                = var.prefix
  source_s3_bucket      = aws_s3_bucket.segment_storage.id
  destination_s3_bucket = aws_s3_bucket.segment_server.id
}
