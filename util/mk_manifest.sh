#!/bin/bash


if [[ $# -ne 1 ]]; then
    echo manifest_ver.sh VERSION
    exit 1
fi

VERSION=$1


docker manifest create cannable/unifi:${VERSION} \
    cannable/unifi:amd64-${VERSION} \
    cannable/unifi:arm64-${VERSION} \
    cannable/unifi:armhf-${VERSION}

docker manifest push --purge cannable/unifi:${VERSION}
