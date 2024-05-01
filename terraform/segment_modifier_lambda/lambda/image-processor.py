import cv2
import face_recognition
import numpy as np
import asyncio
import boto3
import os


def detect_bounding_box(frame):
    print('detecting bounding box')
    rgb_frame = frame[:, :, ::-1]
    face_locations = face_recognition.face_locations(rgb_frame)
    for top, right, bottom, left in face_locations:
        cv2.rectangle(frame, (left, top), (right, bottom), (0, 255, 255), 2)
        cv2.putText(frame, 'Face Detected', (left, top - 10), cv2.FONT_HERSHEY_SIMPLEX, 0.5, (0, 255, 255), 2)

        face_image = frame[top:bottom, left:right]
        blurred_face = cv2.blur(face_image, (99, 99))
        frame[top:bottom, left:right] = blurred_face
    return face_locations


async def process_video_stream(video_stream):
    print('processing video stream', video_stream)
    cap = cv2.VideoCapture(video_stream)
    fourcc = cv2.VideoWriter_fourcc(*'MP4V')
    out = cv2.VideoWriter('output.mp4', fourcc, 20.0, (640, 480))

    if not cap.isOpened():
        print("Error: Unable to open video stream")
        return []

    encode_param = [int(cv2.IMWRITE_JPEG_QUALITY), 90]
    bytes_list = []

    while True:
        result, frame = cap.read()

        if not result:
            break
        faces = detect_bounding_box(frame)
        out.write(frame)

        # result, encimg = cv2.imencode('.jpg', frame, encode_param)

        if result:
            bytes_list.append(frame.tobytes())

    cap.release()
    out.release()
    return bytes_list


async def async_handler(fileObject):
    print('async handler')
    fileContent = fileObject["Body"].read()
    video_path = 'video.ts'
    with open(video_path, 'wb') as f:
        f.write(fileContent)
    byte_list = await process_video_stream(video_path)

    os.remove(video_path)
    return byte_list


def lambda_handler():
    print('Loading function')
    s3 = boto3.client("s3")
    fileObject = s3.get_object(
        Bucket="tasnuva-zaman-segment-storage", Key='data01.ts')
    result = asyncio.run(async_handler(fileObject))
    print('result ', result)

    return {
        'statusCode': 200,
        'body': result
    }


lambda_handler()
