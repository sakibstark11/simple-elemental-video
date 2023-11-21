AWS_REGION=eu-west-1
TERRAFORM_VERSION=1.6.4
AWS_CLI_IMAGE=amazon/aws-cli
TERRAFORM_IMAGE=hashicorp/terraform:${TERRAFORM_VERSION}
DOCKER_ENV=-e AWS_ACCESS_KEY_ID -e AWS_SECRET_ACCESS_KEY -e AWS_DEFAULT_REGION
DOCKER_RUN_MOUNT_OPTIONS=-v ${CURDIR}/:/app -w /app
FFMPEG_IMAGE=jrottenberg/ffmpeg

define run_docker
	docker run -it --rm ${DOCKER_ENV} ${DOCKER_RUN_MOUNT_OPTIONS}
endef

tf-init:
	$(run_docker) ${TERRAFORM_IMAGE} init

tf-plan:
	$(run_docker) ${TERRAFORM_IMAGE} plan

tf-apply:
	$(run_docker) ${TERRAFORM_IMAGE} apply --auto-approve

tf-destroy:
	$(run_docker) ${TERRAFORM_IMAGE} destroy --auto-approve

define get_output
	$(run_docker) ${TERRAFORM_IMAGE} output $(1)
endef

MEDIACONNECT_FLOW_ARN:=$(shell $(call get_output,mediaconnect_flow_arn))
MEDIALIVE_CHANNEL_ID:=$(shell $(call get_output,medialive_channel_id))
MEDIACONNECT_INGRESS_IP:=$(shell $(call get_output,mediaconnect_ingress_ip))
MEDIACONNECT_INGEST_PORT:=$(shell $(call get_output,mediaconnect_ingest_port))

start-pipeline: 
	$(run_docker) ${AWS_CLI_IMAGE} mediaconnect start-flow --flow-arn $(MEDIACONNECT_FLOW_ARN) --region $(AWS_REGION) --query "Status" --no-cli-pager
	$(run_docker) ${AWS_CLI_IMAGE} medialive start-channel --channel-id $(MEDIALIVE_CHANNEL_ID) --region $(AWS_REGION) --query "State" --no-cli-pager
	$(run_docker) ${AWS_CLI_IMAGE} medialive wait channel-running --channel-id $(MEDIALIVE_CHANNEL_ID) --region $(AWS_REGION)
	$(run_docker) ${AWS_CLI_IMAGE} mediaconnect wait flow-active --flow-arn $(MEDIACONNECT_FLOW_ARN) --region $(AWS_REGION)

stop-pipeline: 
	$(run_docker) ${AWS_CLI_IMAGE} mediaconnect stop-flow --flow-arn $(MEDIACONNECT_FLOW_ARN) --region $(AWS_REGION) --query "Status" --no-cli-pager
	$(run_docker) ${AWS_CLI_IMAGE} medialive stop-channel --channel-id $(MEDIALIVE_CHANNEL_ID) --region $(AWS_REGION) --query "State" --no-cli-pager
	$(run_docker) ${AWS_CLI_IMAGE} medialive wait channel-stopped --channel-id $(MEDIALIVE_CHANNEL_ID) --region $(AWS_REGION)
	$(run_docker) ${AWS_CLI_IMAGE} mediaconnect wait flow-standby --flow-arn $(MEDIACONNECT_FLOW_ARN) --region $(AWS_REGION)

start-streaming:
	docker run -it ${FFMPEG_IMAGE} -f lavfi -i testsrc=size=1920x1080:rate=25 -f lavfi -re -i sine=frequency=1000:sample_rate=44010 -f mpegts srt://$(MEDIACONNECT_INGRESS_IP):$(MEDIACONNECT_INGEST_PORT)
