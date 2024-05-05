FROM python:3.11.9-slim-bookworm

ARG TERRAFORM_VERSION

RUN apt-get update \
    && apt-get install -y wget unzip build-essential python3-dev python3-pip cmake pkg-config gcc g++  \
    && rm -rf /var/lib/apt/lists/*

RUN wget https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip \
    && unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip \
    && mv terraform /usr/local/bin/ \
    && rm terraform_${TERRAFORM_VERSION}_linux_amd64.zip
