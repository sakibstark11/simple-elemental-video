AWS_REGION=eu-west-1
TERRAFORM_VERSION=1.6.4
AWS_CLI_IMAGE=amazon/aws-cli
TERRAFORM_IMAGE=hashicorp/terraform:${TERRAFORM_VERSION}
DOCKER_ENV=-e AWS_ACCESS_KEY_ID -e AWS_SECRET_ACCESS_KEY -e AWS_DEFAULT_REGION
DOCKER_RUN_MOUNT_OPTIONS=-v ${CURDIR}/:/app -w /app

tf-init:
	docker run -it --rm ${DOCKER_ENV} ${DOCKER_RUN_MOUNT_OPTIONS} ${TERRAFORM_IMAGE} init

tf-plan:
	docker run -it --rm ${DOCKER_ENV} ${DOCKER_RUN_MOUNT_OPTIONS} ${TERRAFORM_IMAGE} plan

tf-apply:
	docker run -it --rm ${DOCKER_ENV} ${DOCKER_RUN_MOUNT_OPTIONS} ${TERRAFORM_IMAGE} apply --auto-approve

tf-output-%:
	docker run -it --rm ${DOCKER_ENV} ${DOCKER_RUN_MOUNT_OPTIONS} ${TERRAFORM_IMAGE} output $*

start-pipeline: 
	docker run -it --rm ${DOCKER_ENV} ${DOCKER_RUN_MOUNT_OPTIONS} ${AWS_CLI_IMAGE} mediaconnect start-flow --flow-arn $(MEDIA_CONNECT_FLOW_ARN)
