import json
import os

import boto3
from postStreamToMediaPackage import postStreamToMultipleMediaPackageEndpoints


def getS3FileDetailsFromEvent(event):
    return {
        "bucketName": event["Records"][0]["s3"]["bucket"]["name"],
        "key": event["Records"][0]["s3"]["object"]["key"],
        "fileName": event["Records"][0]["s3"]["object"]["key"].split("/")[-1],
    }


s3 = boto3.client("s3")


def handler(event, context):

    s3FileDetails = getS3FileDetailsFromEvent(event)
    fileObject = s3.get_object(
        Bucket=s3FileDetails["bucketName"], Key=s3FileDetails["key"])
    fileContent = fileObject["Body"].read()

    envVariablesList = os.getenv("mediapackage_hls_ingest_endpoints")

    ingestResult = postStreamToMultipleMediaPackageEndpoints(
        json.loads(envVariablesList),
        s3FileDetails["fileName"],
        fileContent,
        {"contentLength": fileObject['ContentLength'],
            "contentType": "application/octet-stream"},
    )

    print(ingestResult)
    return ingestResult
