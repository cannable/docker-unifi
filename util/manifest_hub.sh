#!/bin/bash

. ./env_build.sh

if [[ $# -ne 1 ]]; then
    echo Create a manifest on the Docker Hub
    echo maifest.sh version
    exit 1
fi

version=$1

buildah manifest create "${IMAGE}:${version}"

for arch in ${ARCHES[@]}; do
    buildah manifest add "${IMAGE}:${version}" "docker.io/${IMAGE}:${arch}-${version}"
done

buildah manifest push -f v2s2 "${IMAGE}:${version}" "docker://${IMAGE}:${version}"

buildah manifest rm "${IMAGE}:${version}"
