FROM public.ecr.aws/lambda/python:3.11
WORKDIR /app
COPY lambda/ .
RUN pip install --no-cache-dir -r requirements.txt --force-reinstall
CMD ["handler.handler"]
