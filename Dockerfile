FROM python:3.9-alpine3.13
LABEL maintainer="Biju Tholath"

# Set environment variables (fixing legacy format warning)
ENV PYTHONUNBUFFERRED 1

# Set working directory
WORKDIR  /app

# Copy requirements first to leverage Docker caching
COPY ./requirements.txt /tmp/requirements.txt
COPY ./requirements_dev.txt /tmp/requirements_dev.txt

# Copy the application code
COPY ./app /app


EXPOSE 8000

ARG DEV=false

# Install dependencies
RUN python -m venv /py && \
    /py/bin/pip install --upgrade pip && \
    apk add --update --no-cache postgresql-client jpeg-dev && \
    apk add --update --no-cache --virtual .tmp-build-deps \
    build-base postgresql-dev musl-dev zlib zlib-dev linux-headers && \    
    /py/bin/pip install -r /tmp/requirements.txt && \
    if [ $DEV = "true" ]; \
    then /py/bin/pip install -r /tmp/requirements_dev.txt;  \
    fi && \    
    rm -rf /tmp && \
    apk del .tmp-build-deps && \
    adduser \
    --disabled-password \
    --no-create-home  \
    django-user


ENV PATH="/py/bin:$PATH"

USER django-user
