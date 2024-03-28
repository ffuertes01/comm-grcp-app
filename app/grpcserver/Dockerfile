FROM python:3.11-alpine3.18

WORKDIR /app

COPY . /app/grpcserver

RUN pip install --no-cache-dir -r /app/grpcserver/requirements.txt

EXPOSE 50051

CMD ["python", "grpcserver/comm_server.py"]