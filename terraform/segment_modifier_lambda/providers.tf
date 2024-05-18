data "aws_ecr_authorization_token" "token" {}

provider "docker" {
  host = "unix:///var/run/docker.sock"

  registry_auth {
    address  = data.aws_ecr_authorization_token.token.proxy_endpoint
    username = data.aws_ecr_authorization_token.token.user_name
    password = data.aws_ecr_authorization_token.token.password
  }
}

terraform {
  required_providers {
    docker = {
      source = "kreuzwerker/docker"
    }
  }
}
