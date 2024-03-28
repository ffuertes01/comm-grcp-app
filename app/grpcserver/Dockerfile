FROM public.ecr.aws/docker/library/python:3.11-alpine3.16

WORKDIR /app

COPY . /app/grpcserver

RUN pip install --no-cache-dir -r /app/grpcserver/requirements.txt

EXPOSE 50051

CMD ["python", "grpcserver/comm_server.py"]
