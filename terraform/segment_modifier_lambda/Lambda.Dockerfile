FROM --platform=linux/amd64 public.ecr.aws/lambda/python:3.11
WORKDIR ${LAMBDA_TASK_ROOT}
COPY lambda/ ${LAMBDA_TASK_ROOT}
RUN chmod -R 777 ./
RUN pip install --no-cache-dir -r requirements.txt --force-reinstall
CMD ["handler.handler"]
