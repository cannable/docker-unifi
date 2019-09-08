#!/bin/sh

if [[ $# -ne 2 ]]; then
    echo ver_docker_build.sh ARCH VERSION
    exit 1
fi

ARCH=$1
VERSION=$2

docker build --no-cache \
    --build-arg UNIFI_VERSION=${VERSION} \
    -t "cannable/unifi:${ARCH}-${VERSION}" \
    -f ./Dockerfile .
