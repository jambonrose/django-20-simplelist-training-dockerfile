FROM python:3.6.4-alpine3.6

ENV PYTHONUNBUFFERED 1

WORKDIR /app

COPY requirements.txt /tmp/requirements.txt
RUN apk add --no-cache --virtual .build-deps build-base libffi-dev \
    && apk add --no-cache postgresql-dev \
    && python3.6 -m pip install --no-cache-dir -r /tmp/requirements.txt \
    && apk del .build-deps

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]
