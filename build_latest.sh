#!/bin/bash


if [[ $# -ne 2 ]]; then
    echo build_latest.sh ARCH VERSION
    exit 1
fi

ARCH=$1
VERSION=$2

./ver_docker_build.sh ${ARCH} ${VERSION}

docker tag "cannable/unifi:${ARCH}-${VERSION}" "cannable/unifi:${ARCH}-latest"
