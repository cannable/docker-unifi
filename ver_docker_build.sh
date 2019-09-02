#!/bin/sh

if [[ $# -ne 1 ]]; then
    echo ver_docker_build.sh VERSION
    exit 1
fi

VERSION=$1

docker build --no-cache \
    --build-arg UNIFI_VERSION=${VERSION} \
    -t cannable/unifi:${VERSION} \
    -f ./Dockerfile .
