variable "prefix" {
  type        = string
  description = "will be applied where possible"
}

variable "source_s3_bucket" {
  type        = string
  description = "s3 bucket that will trigger this lambda"
}

variable "mediapackage_hls_ingest_endpoints" {
  type = list(object({
    password = string
    url      = string
    username = string
  }))
  sensitive   = true
  description = "list of mediapackage hls ingest endpoints"
}
