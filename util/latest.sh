#!/bin/bash

IMAGE="cannable/unifi"
ARCHES=(amd64 arm64)

if [[ $# -ne 1 ]]; then
    echo Make an existing tag latest.
    echo latest.sh version
    exit 1
fi

version=$1

buildah manifest create "${IMAGE}:latest"

for arch in ${ARCHES[@]}; do
    buildah manifest add "${IMAGE}:latest" "docker.io/${IMAGE}:${arch}-${version}"
done

buildah manifest push -f v2s2 "${IMAGE}:latest" "docker://${IMAGE}:latest"

buildah manifest rm "${IMAGE}:latest"
