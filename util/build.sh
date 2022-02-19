#!/bin/bash


# ------------------------------------------------------------------------------
# Buildah Build Script
# ------------------------------------------------------------------------------

. ./env_build.sh


### Command-line Argument Handling
if [[ $# -ne 2 ]]; then
    echo Build container images
    echo build.sh version hash
    exit 1
fi

version=$1
hash=$2

url="${PKG_URL_PREFIX}/${version}-${hash}/${PKG_URL_FILENAME}"
cachedir="./cache"
cachefile="${cachedir}/${version}-${PKG_URL_FILENAME}"


### Cache Unifi deb package

# Create cache directory, if it doesn't exist yet
if [ ! -d "${cachedir}" ]; then
    mkdir "${cachedir}"
fi

if [ ! -f "${cachefile}" ]; then
    echo Caching ${UNIFI_VERSION} deb from ${url}...
    curl -o "${cachefile}" "${url}"
else
    echo Using cached ${cachefile}.
fi


### Build architecture-specific images
for arch in ${ARCHES[@]}; do
    buildah bud \
        --arch "$arch" \
        --tag "${IMAGE}:${arch}-${version}" \
        --build-arg "UNIFI_VERSION=${version}" \
        --build-arg "UNIFI_PKG_PATH=${cachefile}" \
        -f ./Dockerfile .
done
