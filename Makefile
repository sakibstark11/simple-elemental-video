AWS_REGION=eu-west-1
TERRAFORM_VERSION=1.6.4
AWS_CLI_IMAGE=amazon/aws-cli
TF_BACKEND_S3_BUCKET=simple-elemental-video-backend
TERRAFORM_IMAGE=hashicorp/terraform:${TERRAFORM_VERSION}
DOCKER_ENV=-e AWS_ACCESS_KEY_ID -e AWS_SECRET_ACCESS_KEY -e AWS_DEFAULT_REGION
DOCKER_RUN_MOUNT_OPTIONS=-v ${CURDIR}/:/ -w /

tf-init:
	docker run -it hashicorp/terraform:${TERRAFORM_VERSION} ${DOCKER_ENV} ${DOCKER_RUN_MOUNT_OPTIONS} init

tf-plan:
	docker run -it hashicorp/terraform:${TERRAFORM_VERSION} ${DOCKER_ENV} ${DOCKER_RUN_MOUNT_OPTIONS} plan
