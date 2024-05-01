import json
import cv2
import face_recognition
import asyncio
import os

import boto3
from postStreamToMediaPackage import postStreamToMediaPackage, postStreamToMultipleMediaPackageEndpoints


def detect_bounding_box(frame):
    print('detecting bounding box')
    rgb_frame = frame[:, :, ::-1]
    face_locations = face_recognition.face_locations(rgb_frame)
    for top, right, bottom, left in face_locations:
        cv2.rectangle(frame, (left, top), (right, bottom), (0, 255, 255), 2)
        face_image = frame[top:bottom, left:right]
        blurred_face = cv2.blur(face_image, (99, 99))
        frame[top:bottom, left:right] = blurred_face
    return face_locations


def process_video_stream(video_stream):
    print('processing video stream', video_stream)
    cap = cv2.VideoCapture(video_stream)
    frame_width = int(cap.get(3))
    frame_height = int(cap.get(4))
    # out = cv2.VideoWriter('output.avi', cv2.VideoWriter_fourcc('M', 'J', 'P', 'G'), 10, (frame_width, frame_height))

    if not cap.isOpened():
        print("Error: Unable to open video stream")
        return
    frames = []
    while True:
        result, frame = cap.read()

        if result is False:
            break

        boxes = detect_bounding_box(frame)
        # out.write(frame)
        cv2.imshow('Video', frame)

        if cv2.waitKey(1) & 0xFF == ord('q'):
            break

    cap.release()
    cv2.destroyAllWindows()

    encode_param = [int(cv2.IMWRITE_JPEG_QUALITY), 90]
    bytes_list = []
    for frame in frames:
        result, encimg = cv2.imencode('.jpg', frame, encode_param)
        if result:
            bytes_list.append(encimg.tobytes())

    os.remove(video_stream)

    return bytes_list


async def async_handler(fileContent):
    video_path = '/tmp/video.ts'
    with open(video_path, 'wb') as f:
        f.write(fileContent)
    process_video_stream(video_path)
    await asyncio.sleep(1)

    return 'success'


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
        { "contentLength": fileObject['ContentLength'], "contentType": "application/octet-stream" },
    )
    #
    print(ingestResult)
    return ingestResult
handler({}, {})