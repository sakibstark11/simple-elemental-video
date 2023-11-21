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

    MedialiveChannel = {
      DependsOn = ["MedialiveInput"]
      Type      = "AWS::MediaLive::Channel"
      Properties = {
        Name    = "${var.prefix}-medialive-channel"
        RoleArn = aws_iam_role.medialive_iam_role.arn
        InputAttachments = [
          {
            InputId = {
              Ref = "MedialiveInput"
            }
            InputSettings = {
              SourceEndBehavior = "CONTINUE"
            }
          }
        ]
        ChannelClass = "SINGLE_PIPELINE"
        Destinations = [
          {
            Id = "${var.prefix}-destination-${var.mediapackage_channel_id}"
            MediaPackageSettings = [
              {
                ChannelId = var.mediapackage_channel_id
              }
            ]
          }
        ]
        EncoderSettings = {
          AudioDescriptions = [
            {
              AudioTypeControl = "FOLLOW_INPUT"
              CodecSettings = {
                AacSettings = {
                  Bitrate    = 96000
                  CodingMode = "CODING_MODE_2_0"
                  SampleRate = 48000
                }
              }
              LanguageCode = "ENG"
              Name         = "${var.prefix}-medialive-channel-audio-descriptor"
              RemixSettings = {
                ChannelsIn  = 2
                ChannelsOut = 2
              }
            }
          ]
          VideoDescriptions = [
            {
              Width           = 1920
              Height          = 1080
              ScalingBehavior = "DEFAULT",
              Sharpness       = 50
              CodecSettings = {
                H264Settings = {
                  Bitrate           = 5000000
                  RateControlMode   = "CBR"
                  SceneChangeDetect = "ENABLED"
                  NumRefFrames      = 3
                  Level             = "H264_LEVEL_AUTO"
                  MaxBitrate        = 5000000
                  BufSize           = 10000000
                  GopSizeUnits      = "FRAMES"
                  ParControl        = "INITIALIZE_FROM_SOURCE"
                }
              },
              Name = "${var.prefix}-medialive-channel-video-descriptor"
            }
          ]
        }
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
        InputAttachmentName = "${var.prefix}-input-attachment"
        InputId             = ""
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
