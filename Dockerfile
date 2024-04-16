# Use Terraform 1.8.0 as base image
FROM hashicorp/terraform:1.8.0

# Install necessary dependencies
RUN apk add --no-cache \
    python3=3.11.9-r0 py3-pip && \
    rm -rf /var/cache/apk/*
