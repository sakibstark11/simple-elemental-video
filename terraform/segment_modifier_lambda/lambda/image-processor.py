import cv2
import face_recognition
import numpy as np
import asyncio
import boto3
import os


async def async_handler(event, context, fileObject):
    print('fileObject ', fileObject)
    fileContent = fileObject["Body"].read()
    video_path = 'video.ts'
    with open(video_path, 'wb') as f:
        f.write(fileContent)
    process_video_stream(video_path)
    await asyncio.sleep(1)

    return 'Success'


def lambda_handler(event, context):
    s3 = boto3.client("s3")
    fileObject = s3.get_object(
        Bucket="tasnuva-zaman-segment-storage", Key='41.png')
    result = asyncio.run(async_handler(event, context, fileObject))

    return {
        'statusCode': 200,
        'body': result
    }


lambda_handler({}, {})


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

    if not cap.isOpened():
        print("Error: Unable to open video stream")
        return

    while True:
        result, frame = cap.read()
        if result is False:
            break
        small_frame = cv2.resize(frame, (0, 0), fx=0.25, fy=0.25)
        faces = detect_bounding_box(small_frame)

        cv2.imshow('Video', small_frame)

        if cv2.waitKey(1) & 0xFF == ord('q'):
            break
    cap.release()
    cv2.destroyAllWindows()
    os.remove(video_stream)
