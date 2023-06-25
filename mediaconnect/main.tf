locals {
  cloudformation_resources = {
    Mediaconnect = {
      Type = "AWS::MediaConnect::Flow"
      Properties = {
        Name = "${var.prefix}-source"
        Source = {
          IngestPort    = 5000
          Name          = "${var.prefix}-srt-5000",
          Protocol      = "srt-listener",
          WhitelistCidr = "${var.whitelist_cidr_address}/32"
        }
      }
    }
  }

  cloudformation_outputs = {
    IngressIp = {
      Value = { "Fn::GetAtt" = ["Mediaconnect", "Source.IngestIp"] }
    }
    IngressArn = {
      Value = { "Fn::GetAtt" = ["Mediaconnect", "Source.SourceArn"] }
    }
  }

  cloudformation_body = {
    AWSTemplateFormatVersion = "2010-09-09"
    Resources                = local.cloudformation_resources
    Outputs                  = local.cloudformation_outputs
  }
}

resource "aws_cloudformation_stack" "mediaconnect" {
  name          = "${var.prefix}-mediaconnect"
  template_body = jsonencode(local.cloudformation_body)
}
