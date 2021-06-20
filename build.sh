#!/bin/bash

. ./env_build.sh

if [[ $# -ne 1 ]]; then
    echo build.sh version
    exit 1
fi

version=$1

for arch in ${ARCHES[@]}; do
    buildah bud --arch "$arch" --tag "${IMAGE}:${arch}-${version}" --build-arg "${VERSION_ARG}=${version}" -f ./Dockerfile .
    buildah push -f v2s2 "${IMAGE}:${arch}-${version}" "docker://${IMAGE}:${arch}-${version}"
done

buildah manifest create "${IMAGE}:${version}"

for arch in ${ARCHES[@]}; do
    buildah manifest add "${IMAGE}:${version}" "docker.io/${IMAGE}:${arch}-${version}"
done

buildah manifest push -f v2s2 "${IMAGE}:${version}" "docker://${IMAGE}:${version}"

buildah manifest rm "${IMAGE}:${version}"
