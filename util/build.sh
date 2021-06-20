#!/bin/bash

. ./env_build.sh

if [[ $# -ne 1 ]]; then
    echo Build container images
    echo build.sh version
    exit 1
fi

version=$1

for arch in ${ARCHES[@]}; do
    buildah bud --arch "$arch" --tag "${IMAGE}:${arch}-${version}" --build-arg "${VERSION_ARG}=${version}" -f ./Dockerfile .
done
