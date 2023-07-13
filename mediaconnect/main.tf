locals {
  ingress_port = 5000
  cloudformation_resources = {
    Mediaconnect = {
      Type = "AWS::MediaConnect::Flow"
      Properties = {
        Name = "${var.prefix}-source"
        Source = {
          IngestPort    = local.ingress_port
          Name          = "${var.prefix}-srt-${local.ingress_port}",
          Protocol      = "srt-listener",
          WhitelistCidr = var.whitelist_cidr_address
        }
      }
    }
  }

  cloudformation_outputs = {
    IngressIp = {
      Value = { "Fn::GetAtt" = ["Mediaconnect", "Source.IngestIp"] }
    }
    IngressArn = {
      Value = { "Fn::GetAtt" = ["Mediaconnect", "FlowArn"] }
    }
  }

  cloudformation_body = {
    AWSTemplateFormatVersion = "2010-09-09"
    Resources                = local.cloudformation_resources
    Outputs                  = local.cloudformation_outputs
  }
}

resource "aws_cloudformation_stack" "mediaconnect" {
  name          = "${var.prefix}-mediaconnect-flow"
  template_body = jsonencode(local.cloudformation_body)
}
