TERRAFORM_VERSION?=1.6.4
TF_BACKEND_S3_BUCKET=simple-elemental-video-backend
AWS_REGION=eu-west-1
AWS_PROFILE=my-profile

tf-init:
	docker run -it hashicorp/terraform:${TERRAFORM_VERSION} plan


tf-plan:
	docker run -it hashicorp/terraform:${TERRAFORM_VERSION} plan

tf-backend:
	docker run --rm -it -v ~/.aws:/root/.aws amazon/aws-cli s3api create-bucket --bucket ${TF_BACKEND_S3_BUCKET} \
		--region ${AWS_REGION} --acl private --profile ${AWS_PROFILE}
