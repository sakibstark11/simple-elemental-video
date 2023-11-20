locals {
  cloudformation_resources_channel = {
    Type = "AWS::MediaPackage::Channel"
    Properties = {
      Id          = "${var.prefix}-channel"
      Description = "Simple Elemental Video Mediapackage Channel"
    }
  }

  cloudformation_body_channel = {
    AWSTemplateFormatVersion = "2010-09-09"
    Resources                = local.cloudformation_resources_channel
  }
}

resource "aws_cloudformation_stack" "mediapackage_channel" {
  name          = "${var.prefix}-mediapackage-channel"
  template_body = jsonencode(local.cloudformation_body_channel)
}
