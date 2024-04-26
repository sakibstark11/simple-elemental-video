import os

import boto3

DESTINATION_S3_BUCKET = os.getenv("desitnation_s3_bucket", None)
if not DESTINATION_S3_BUCKET:
    raise AttributeError("Destination S3 bucket not set")

s3 = boto3.client("s3")


def handler(event, context):
    pass
