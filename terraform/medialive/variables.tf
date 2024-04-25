variable "prefix" {
  type        = string
  description = "will be applied where possible"
}

variable "mediaconnect_flow_arn" {
  type        = string
  description = "mediaconnect ingress flow arn to use as input"
}

variable "lambda_url" {
  type        = string
  description = "url to post to"
}
