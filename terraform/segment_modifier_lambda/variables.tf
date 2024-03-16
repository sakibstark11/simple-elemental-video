variable "prefix" {
  type        = string
  description = "will be applied where possible"
}

variable "source_s3_bucket" {
  type        = string
  description = "s3 bucket that will trigger this lambda"
}

variable "destination_s3_bucket" {
  type        = string
  description = "s3 bucket this lambda will upload to"
}
