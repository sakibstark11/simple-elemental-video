provider "aws" {
  profile = var.aws_profile

  default_tags {
    tags = {
      local.project_name = var.billing_tag
    }
  }
}
