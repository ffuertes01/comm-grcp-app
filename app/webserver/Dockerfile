FROM public.ecr.aws/docker/library/python:3.11-alpine3.16

WORKDIR /app

COPY . /app/webserver

RUN pip install --no-cache-dir -r /app/webserver/requirements.txt

EXPOSE 8080

ENTRYPOINT ["python", "webserver/webserver.py"]