#!/bin/bash

. ./env_build.sh

if [[ $# -ne 2 ]]; then
    echo Push image to external Docker registry
    echo push.sh version registry
    exit 1
fi

version=$1
registry=$2

for arch in ${ARCHES[@]}; do
    buildah push -f v2s2 "${IMAGE}:${arch}-${version}" "docker://${registry}/${IMAGE}:${arch}-${version}"
done
