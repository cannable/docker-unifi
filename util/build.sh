#!/bin/bash

. ./env_build.sh

if [[ $# -ne 2 ]]; then
    echo Build container images
    echo build.sh version hash
    exit 1
fi

version=$1
hash=$2

url="${PKG_URL_PREFIX}/${version}-${hash}/${PKG_URL_FILENAME}"

echo "url=${url}"

for arch in ${ARCHES[@]}; do
    buildah bud \
        --arch "$arch" \
        --tag "${IMAGE}:${arch}-${version}" \
        --build-arg "UNIFI_VERSION=${version}" \
        --build-arg "UNIFI_PKG_URL=${url}" \
        -f ./Dockerfile .
done
