import json
import os

import boto3
import requests
from requests.auth import HTTPDigestAuth


def postStreamToMediaPackage(envVariables, fileName, content, contentType):
    mediaPackageUrl = envVariables["url"]
    username = envVariables["username"]
    password = envVariables["password"]
    ingestUrl = f"{mediaPackageUrl.rstrip('/channel')}/{fileName}"

    response = requests.put(
        ingestUrl, data=content, headers={
            "ContentType": contentType
        }, auth=HTTPDigestAuth(username, password))
    if response.status_code != 201:
        print(
            f"Error ingesting file {fileName} to {ingestUrl}. error: {response.text}")
    return {"ingestUrl": ingestUrl, "fileName": fileName, "status": response.status_code}


def getS3FileDetailsFromEvent(event):
    return {
        "bucketName": event["Records"][0]["s3"]["bucket"]["name"],
        "key": event["Records"][0]["s3"]["object"]["key"],
        "fileName": event["Records"][0]["s3"]["object"]["key"].split("/")[-1],
    }


def handler(event, context):
    s3 = boto3.client("s3")

    s3FileDetails = getS3FileDetailsFromEvent(event)
    fileObject = s3.get_object(
        Bucket=s3FileDetails["bucketName"], Key=s3FileDetails["key"])
    fileContent = fileObject["Body"].read()

    envVariablesList = os.getenv("mediapackage_hls_ingest_endpoints")

    ingestResult = [
        postStreamToMediaPackage(
            envVars, s3FileDetails["fileName"], fileContent, fileObject['ContentType'])
        for envVars in json.loads(envVariablesList)]
    print(ingestResult)
    return ingestResult
