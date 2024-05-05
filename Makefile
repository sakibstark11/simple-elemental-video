PREFIX=$(subst .,-,$(USER))
AWS_REGION?=eu-west-1
TERRAFORM_VERSION=1.8.0
AWS_CLI_IMAGE=amazon/aws-cli
DOCKER_ENV=-e AWS_ACCESS_KEY_ID -e AWS_SECRET_ACCESS_KEY -e AWS_DEFAULT_REGION -e AWS_REGION -e PREFIX
DOCKER_RUN_MOUNT_OPTIONS=-v ${CURDIR}/:/app -w /app
FFMPEG_IMAGE=sakibstark11/ffmpeg
TERRAFORM_PYTHON_IMAGE?=local-terraform-python
DOCKER_DEFAULT_PLATFORM=linux/amd64

define run_docker
	docker run --platform=linux/amd64 -it --rm ${DOCKER_ENV} ${DOCKER_RUN_MOUNT_OPTIONS}
endef

define get_output
	$(run_docker) ${TERRAFORM_PYTHON_IMAGE} output $(1)
endef

build-terraform-python-image:
	docker build --build-arg TERRAFORM_VERSION=${TERRAFORM_VERSION} . -t ${TERRAFORM_PYTHON_IMAGE}

tf-init: build-terraform-python-image
	$(run_docker) ${TERRAFORM_PYTHON_IMAGE} terraform init

tf-plan: build-terraform-python-image
	$(run_docker) ${TERRAFORM_PYTHON_IMAGE} terraform plan -var="prefix=${PREFIX}"

tf-apply: build-terraform-python-image
	$(run_docker) ${TERRAFORM_PYTHON_IMAGE} terraform apply --auto-approve -var="prefix=${PREFIX}"

tf-destroy: build-terraform-python-image
	$(run_docker) ${TERRAFORM_PYTHON_IMAGE} terraform destroy --auto-approve -var="prefix=${PREFIX}"

MEDIACONNECT_FLOW_ARN=$(shell $(call get_output,mediaconnect_flow_arn))
MEDIALIVE_CHANNEL_ID=$(shell $(call get_output,medialive_channel_id))
MEDIACONNECT_INGRESS_IP=$(shell $(call get_output,mediaconnect_ingress_ip))
MEDIACONNECT_INGEST_PORT=$(shell $(call get_output,mediaconnect_ingest_port))
MEDIAPACKAGE_HLS_ENDPOINT=$(shell $(call get_output, mediapackage_hls_endpoint))

start-pipeline:
	$(run_docker) ${AWS_CLI_IMAGE} mediaconnect start-flow --flow-arn $(MEDIACONNECT_FLOW_ARN) --region $(AWS_REGION) --query "Status" --no-cli-pager
	$(run_docker) ${AWS_CLI_IMAGE} medialive start-channel --channel-id $(MEDIALIVE_CHANNEL_ID) --region $(AWS_REGION) --query "State" --no-cli-pager
	$(run_docker) ${AWS_CLI_IMAGE} mediaconnect wait flow-active --flow-arn $(MEDIACONNECT_FLOW_ARN) --region $(AWS_REGION)
	$(run_docker) ${AWS_CLI_IMAGE} medialive wait channel-running --channel-id $(MEDIALIVE_CHANNEL_ID) --region $(AWS_REGION)

wait-%:
	sleep $*

stop-pipeline:
	$(run_docker) ${AWS_CLI_IMAGE} mediaconnect stop-flow --flow-arn $(MEDIACONNECT_FLOW_ARN) --region $(AWS_REGION) --query "Status" --no-cli-pager
	$(run_docker) ${AWS_CLI_IMAGE} medialive stop-channel --channel-id $(MEDIALIVE_CHANNEL_ID) --region $(AWS_REGION) --query "State" --no-cli-pager
	$(run_docker) ${AWS_CLI_IMAGE} medialive wait channel-stopped --channel-id $(MEDIALIVE_CHANNEL_ID) --region $(AWS_REGION)
	$(run_docker) ${AWS_CLI_IMAGE} mediaconnect wait flow-standby --flow-arn $(MEDIACONNECT_FLOW_ARN) --region $(AWS_REGION)

start-streaming:
	docker run -itd --rm ${FFMPEG_IMAGE} -f lavfi -i testsrc=size=1920x1080:rate=25 -f lavfi -re -i sine=frequency=1000:sample_rate=44010 -f mpegts srt://$(MEDIACONNECT_INGRESS_IP):$(MEDIACONNECT_INGEST_PORT)

print-hls-playback-url:
	echo https://hlsjs.video-dev.org/demo/?src=$(MEDIAPACKAGE_HLS_ENDPOINT)

deploy: tf-init tf-apply start-pipeline wait-10 start-streaming print-hls-playback-url

destroy: tf-init stop-pipeline tf-destroy
