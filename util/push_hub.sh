#!/bin/bash

. ./env_build.sh

if [[ $# -ne 1 ]]; then
    echo Push image to Docker Hub
    echo push.sh version
    exit 1
fi

version=$1

for arch in ${ARCHES[@]}; do
    buildah push -f v2s2 "${IMAGE}:${arch}-${version}" "docker://${IMAGE}:${arch}-${version}"
done
