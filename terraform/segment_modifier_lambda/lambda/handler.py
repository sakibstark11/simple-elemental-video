import requests
from requests.auth import HTTPDigestAuth
import boto3
import os
import json

def postStreamToMediaPackage(envVariables, fileName, buffer):
    mediaPackageUrl = envVariables["url"]
    username = envVariables["username"]
    password = envVariables["password"]
    ingestUrl = f"{mediaPackageUrl}/{fileName}"
    
    response = requests.put(ingestUrl, data=buffer, auth=HTTPDigestAuth(username, password))
    if response.status_code != 201:
        print(f"Error ingesting file {fileName} to {ingestUrl}. error: {response.text}" )
    return { "ingestUrl": ingestUrl, "fileName": fileName, "status": response.status_code }

def getS3FileDetailsFromEvent(event):
    return {
        "bucketName": event["Records"][0]["s3"]["bucket"]["name"],
        "key": event["Records"][0]["s3"]["object"]["key"],
        "fileName": event["Records"][0]["s3"]["object"]["key"].split("/")[-1],
        "size": event["Records"][0]["s3"]["object"]["size"],
    }

def handler(event, context):
    s3 = boto3.client("s3")

    s3FileDetails = getS3FileDetailsFromEvent(event)
    fileContent = s3.get_object(Bucket=s3FileDetails["bucketName"], Key=s3FileDetails["key"])["Body"].read(s3FileDetails["size"])
    
    envVariablesList = os.getenv("mediapackage_hls_ingest_endpoints")

    ingestResult = [postStreamToMediaPackage(envVars, s3FileDetails["fileName"], fileContent) for envVars in json.loads(envVariablesList)]
    print(ingestResult)
    return ingestResult
