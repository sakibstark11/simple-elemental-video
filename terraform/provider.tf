provider "aws" {
  profile = var.aws_profile

  default_tags {
    tags = {
      "${var.billing_tag}" = local.project_name
    }
  }
}
