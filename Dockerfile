FROM hashicorp/terraform:1.8.0

RUN apk update && apk add docker-cli

WORKDIR /repo
