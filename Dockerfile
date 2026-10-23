# syntax = docker/dockerfile:1.3
# VULN_SCAN_TIME=2024-01-17_12:44:13


# The python base images ship pip 24.0, whose vendored certifi trusts the compromised
# eMudhra CAs; each stage replaces it from this hash-pinned wheel before fetching anything.
ARG PIP_WHEEL="pip @ https://files.pythonhosted.org/packages/3f/06/3e4420302363fbb71be3c7f35ce042f54bfca330e3e66b3a2e3c4cca579f/pip-26.2.2-py3-none-any.whl#sha256=fd7f4dfa8190e014013b9f08f3e973f4e4c26ffd179a204895533a7254813a70"

# The build stage
# ---------------
# This stage is building Python wheels for use in later stages by using a base
# image that has more pre-requisites to do so, such as a C++ compiler.
#
# NOTE: If the image version is updated, also update it in ci/refreeze and
#       hub's Dockerfile!
#
FROM python:3.11-bookworm AS build-stage

ARG PIP_WHEEL
RUN pip install --no-cache-dir "${PIP_WHEEL}"

# Build wheels
#
# We set pip's cache directory and expose it across build stages via an
# ephemeral docker cache (--mount=type=cache,target=${PIP_CACHE_DIR}). We use
# the same technique for the directory /tmp/wheels.
#
COPY requirements.txt requirements.txt
ARG PIP_CACHE_DIR=/tmp/pip-cache
RUN --mount=type=cache,target=${PIP_CACHE_DIR} \
    pip install build \
 && pip wheel \
        --wheel-dir=/tmp/wheels \
        -r requirements.txt


# The final stage
# ---------------
#
FROM python:3.11-slim-bookworm
ENV DEBIAN_FRONTEND=noninteractive
ARG PIP_WHEEL
RUN pip install --no-cache-dir "${PIP_WHEEL}"

ENV NB_USER=jovyan \
    NB_UID=1000 \
    HOME=/home/jovyan
RUN adduser \
        --disabled-password \
        --gecos "Default user" \
        --uid ${NB_UID} \
        --home ${HOME} \
        --force-badname \
        ${NB_USER}

RUN apt-get update \
 && apt-get upgrade --yes \
 && apt-get install --yes --no-install-recommends \
        ca-certificates \
        dnsutils \
        iputils-ping \
        tini \
        # requirement for nbgitpuller
        git \
 && rm -rf /var/lib/apt/lists/*

# install wheels built in the build-stage
COPY requirements.txt /tmp/requirements.txt
ARG PIP_CACHE_DIR=/tmp/pip-cache
RUN --mount=type=cache,target=${PIP_CACHE_DIR} \
    --mount=type=cache,from=build-stage,source=/tmp/wheels,target=/tmp/wheels \
    pip install \
        --find-links=/tmp/wheels/ \
        -r /tmp/requirements.txt

WORKDIR ${HOME}
USER ${NB_USER}

EXPOSE 8888
ENTRYPOINT ["tini", "--"]
CMD ["jupyter", "lab"]
