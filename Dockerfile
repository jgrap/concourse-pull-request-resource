#
# Global Arguments
#
ARG PYTHON_VERSION=3.8

#
# Stage 1: Run Tests
#
FROM python:${PYTHON_VERSION}-alpine

COPY requirements/ /tmp/requirements

RUN pip install --upgrade pip --no-cache-dir && \
    pip install --no-cache-dir -r /tmp/requirements/development.txt && \
    apk update --cache-dir /tmp/cache && \
    apk upgrade && \
    apk add git && \
    rm -rf /tmp/cache

COPY assets/ /opt/assets
COPY tests/ /opt/tests

WORKDIR /opt

RUN TZ='America/Chicago' behave tests/features

#
# Stage 2: Install Python Packages from Requirements
#
FROM python:${PYTHON_VERSION}-alpine AS installer

COPY requirements/ /tmp/requirements

RUN pip install --upgrade pip --no-cache-dir && \
    pip install --no-cache-dir \
        --requirement /tmp/requirements/production.txt \
        --prefix=/tmp \
        --no-warn-script-location

#
# Stage 3: Build Production Image for Resource
#
FROM python:${PYTHON_VERSION}-alpine

COPY assets/ /opt/resource/
COPY --from=installer /tmp/bin/ /usr/local/lib/bin/
COPY --from=installer \
         /tmp/lib/python3.8/site-packages/ \
         /usr/local/lib/python3.8/site-packages/

RUN ln -s /opt/resource/check.py /opt/resource/check && \
    ln -s /opt/resource/in.py    /opt/resource/in    && \
    ln -s /opt/resource/out.py   /opt/resource/out
