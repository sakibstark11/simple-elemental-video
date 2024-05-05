FROM --platform=linux/amd64 python:3.11.9-slim-bookworm

ARG TERRAFORM_VERSION

RUN apt-get update \
    && apt-get install -y wget libwebp-dev libtiff-dev libopenexr-dev libjpeg-dev libpng-dev unzip build-essential cmake libglib2.0-0 libgl1-mesa-glx python3-dev python3-pip libgtk-3-dev libboost-python-dev python3-dev python3-pip build-essential cmake pkg-config libx11-dev libatlas-base-dev python3-numpy gcc g++  \
    && rm -rf /var/lib/apt/lists/*

RUN wget https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip \
    && unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip \
    && mv terraform /usr/local/bin/ \
    && rm terraform_${TERRAFORM_VERSION}_linux_amd64.zip
