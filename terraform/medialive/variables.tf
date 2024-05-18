variable "prefix" {
  type        = string
  description = "will be applied where possible"
}

variable "mediaconnect_flow_arn" {
  type        = string
  description = "mediaconnect ingress flow arn to use as input"
}

variable "segment_storage_bucket" {
  type        = string
  description = "bucket to dump segments in"
}
