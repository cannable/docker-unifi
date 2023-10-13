#!/bin/bash

# ------------------------------------------------------------------------------
# Build Multiple Images
# ------------------------------------------------------------------------------
# A bit of light scripting to build images across architectures at once.

# ------------------------------------------------------------------------------
# Defaults

IMAGE="cannable/unifi"
ARCHES=(amd64 arm64)


# ------------------------------------------------------------------------------
# Function Definitions

# printUsage -- Print the customary help/usage blurb.
printUsage() {
    echo ""
    echo "Usage: $0 unifi_version"
    echo "ex.    $0 7.5.176"
    echo ""
}


# ------------------------------------------------------------------------------
# Handle command line arguments

if [[ $# -ne 1 ]]; then
    printUsage
    exit 1
fi

UNIFI_VERSION=$1


# ------------------------------------------------------------------------------
# 'Main'

# Build is hard-coded to buildah for now
for ARCH in ${ARCHES[@]}; do
  ./util/build.sh -b -a $ARCH -u $UNIFI_VERSION
done

