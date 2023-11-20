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

  cloudformation_outputs_ml_input = {
    InputId = {
      Value = { "Fn::GetAtt" = ["Medialive", "Id"] }
    }
  }

  cloudformation_body_input = {
    AWSTemplateFormatVersion = "2010-09-09"
    Resources                = local.cloudformation_resources_input
    Outputs                  = local.cloudformation_outputs_ml_input
  }
}

resource "aws_cloudformation_stack" "medialive_input" {
  name          = "${var.prefix}-medialive-input"
  template_body = jsonencode(local.cloudformation_body_input)
}
