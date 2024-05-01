import json
import cv2
import asyncio
import os

import boto3
from postStreamToMediaPackage import postStreamToMediaPackage, postStreamToMultipleMediaPackageEndpoints

face_classifier = cv2.CascadeClassifier(
    cv2.data.haarcascades + "haarcascade_frontalface_default.xml"
)


def detect_label_and_blur_faces(frame):
    gray_image = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)
    faces = face_classifier.detectMultiScale(gray_image, 1.1, 6, minSize=(40, 40))
    for (x, y, w, h) in faces:
        roi = frame[y:y + h, x:x + w]
        blurred_roi = cv2.blur(roi, (30, 30))
        frame[y:y + h, x:x + w] = blurred_roi
        cv2.rectangle(frame, (x, y), (x + w, y + h), (0, 255, 0), 4)
        cv2.putText(frame, 'Face', (x, y - 10), cv2.FONT_HERSHEY_SIMPLEX, 0.9, (0, 255, 0), 2)
    return faces


async def process_video_stream(video_stream):
    print('Processing video stream...')

    cap = cv2.VideoCapture(video_stream)
    # fourcc = cv2.VideoWriter_fourcc(*'MP4V')
    # out = cv2.VideoWriter('output.mp4', fourcc, 20.0, (640, 480))

    if not cap.isOpened():
        print("Error: Unable to open video stream")
        return []

    bytes_list = []

    while True:
        result, frame = cap.read()

        if not result:
            break
        faces = detect_label_and_blur_faces(frame)
        # out.write(frame)
        if result:
            bytes_list.append(frame.tobytes())

    cap.release()
    # out.release()
    return bytes_list


async def async_handler(fileObject):
    print('async handler')
    fileContent = fileObject["Body"].read()
    video_path = '/tmp/video.ts'
    with open(video_path, 'wb') as f:
        f.write(fileContent)
    byte_list = await process_video_stream(video_path)

    os.remove(video_path)
    return byte_list


def getS3FileDetailsFromEvent(event):
    return {
        "bucketName": event["Records"][0]["s3"]["bucket"]["name"],
        "key": event["Records"][0]["s3"]["object"]["key"],
        "fileName": event["Records"][0]["s3"]["object"]["key"].split("/")[-1],
    }


def handler(event, context):
    s3 = boto3.client("s3")
    s3FileDetails = getS3FileDetailsFromEvent(event)
    fileName = s3FileDetails["fileName"]

    fileObject = s3.get_object(
        Bucket=s3FileDetails["bucketName"], Key=s3FileDetails["key"])
    fileContent = fileObject["Body"].read()

    if fileName.endswith('.m3u8'):
        content = fileContent
    else:
        content = asyncio.run(async_handler(fileContent))

    envVariablesList = os.getenv("mediapackage_hls_ingest_endpoints")

    # ingestResult = [
    #     postStreamToMediaPackage(
    #         envVars, s3FileDetails["fileName"],
    #         fileContent,
    #         { "contentLength": fileObject['ContentLength'], "contentType": "application/octet-stream" }
    #     ) for envVars in json.loads(envVariablesList)
    # ]
    ingestResult = postStreamToMultipleMediaPackageEndpoints(
        json.loads(envVariablesList),
        fileName,
        content,
        {"contentLength": fileObject['ContentLength'], "contentType": "application/octet-stream"},
    )
    #
    print(ingestResult)
    return ingestResult


handler({}, {})
