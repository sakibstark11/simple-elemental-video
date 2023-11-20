locals {
  cloudformation_resources_channel = {
    Type = "AWS::MediaLive::Channel"
    Properties = {
      ChannelClass    = "SINGLE_PIPELINE"
      Destinations    = []
      EncoderSettings = ""  // FIXME: add settings
      InputAttachments = [{
        InputAttachmentName : "${var.prefix}-input-attachment"
        InputId : aws_cloudformation_stack.medialive_input.outputs.InputId
      }]
      InputSpecification = ""
      LogLevel           = "INFO"
      Maintenance        = ""
      Name               = "${var.prefix}-channel"
      RoleArn            = ""  // FIXME: add role arn with mediapackage
    }
  }

  cloudformation_body_channel = {
    AWSTemplateFormatVersion = "2010-09-09"
    Resources                = local.cloudformation_resources_channel
  }
}

resource "aws_cloudformation_stack" "medialive_input" {
  name          = "${var.prefix}-medialive-channel"
  template_body = jsonencode(local.cloudformation_body_channel)
}
