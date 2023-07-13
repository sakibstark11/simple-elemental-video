locals {
  cloudformation_resources_input = {
    MedialiveInput = {
      Type = "AWS::MediaLive::Input"
      Properties = {
        MediaConnectFlows = [
          {
            FlowArn = var.ingress_flow_arn
          }
        ]
        Name    = "${var.prefix}-medialive-input"
        Type    = "MEDIACONNECT"
        RoleArn = aws_iam_role.medialive_iam_role.arn
      }
    }
  }

  cloudformation_body_input = {
    AWSTemplateFormatVersion = "2010-09-09"
    Resources                = local.cloudformation_resources_input
  }
}

resource "aws_cloudformation_stack" "medialive_input" {
  name          = "${var.prefix}-medialive-input"
  template_body = jsonencode(local.cloudformation_body_input)
}

data "aws_iam_policy_document" "medialive_iam_trust_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["medialive.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "medialive_iam_mediaconnect_policy" {
  statement {
    actions = [
      "mediaconnect:ManagedDescribeFlow",
      "mediaconnect:ManagedAddOutput",
      "mediaconnect:ManagedRemoveOutput"
    ]
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "medialive_iam_logs_policy" {
  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogStreams",
      "logs:DescribeLogGroups"
    ]
    resources = ["arn:aws:logs:*:*:*"]
  }
}

data "aws_iam_policy_document" "medialive_iam_mediapackage_policy" {
  statement {
    actions   = ["mediapackage:DescribeChannel"]
    resources = ["*"]
  }
}

resource "aws_iam_role" "medialive_iam_role" {
  name               = "${var.prefix}-medialive-role"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.medialive_iam_trust_policy.json
  inline_policy {
    name   = "mediaconnect-input"
    policy = data.aws_iam_policy_document.medialive_iam_mediaconnect_policy.json
  }
  inline_policy {
    name   = "logs"
    policy = data.aws_iam_policy_document.medialive_iam_logs_policy.json
  }
  inline_policy {
    name   = "mediapackage"
    policy = data.aws_iam_policy_document.medialive_iam_mediapackage_policy.json
  }
}

locals {
  cloudformation_resources_channel = {
    Type = "AWS::MediaLive::Channel"
    Properties = {
      ChannelClass    = "SINGLE_PIPELINE"
      Destinations    = []
      EncoderSettings = ""
      InputAttachments = [{
        InputAttachmentName : "${var.prefix}-input-attachment"
        InputId : ""
      }]
      InputSpecification = ""
      LogLevel           = "INFO"
      Maintenance        = ""
      Name               = ""
      RoleArn            = ""
    }
  }

  cloudformation_body_channel = {
    AWSTemplateFormatVersion = "2010-09-09"
    Resources                = local.cloudformation_resources_channel
  }
}
