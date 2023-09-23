#!/bin/bash

# ------------------------------------------------------------------------------
# Build Container Image
# ------------------------------------------------------------------------------
# This script provides some scaffolding to make building multiple images at once
# easier.

# ------------------------------------------------------------------------------
# Defaults

DEFAULT_BUILDER="buildah"
DEFAULT_BUILD_ARCH=""
DEFAULT_CACHE_DIR="./cache"
DEFAULT_DOCKER_FILE="./Dockerfile"
DEFAULT_NAME="cannable/unifi"
DEFAULT_UNIFI_VERSION=7.5.176


# ------------------------------------------------------------------------------
# Function Definitions

# printUsage -- Print the customary help/usage blurb.
printUsage() {
    echo ""
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "The default builder is ${DEFAULT_BUILDER}."
    echo ""
    echo "Options:"
    echo "    -a arch      Set the architecture for build."
    echo "                 To use this for creating multiarch images, you need"
    echo "                 qemu-user-static set up properly."
    echo "    -b           Build with buildah."
    echo "    -c path      Set the artifact cache directory."
    echo "                 Defaults to ${DEFAULT_CACHE_DIR}"
    echo "    -d           Build with docker."
    echo "    -f file      Set Dockerfile."
    echo "                 Defaults to ${DEFAULT_DOCKER_FILE}"
    echo "    -h           Print this help."
    echo "    -n name      Set image name."
    echo "                 Defaults to ${DEFAULT_NAME}"
    echo "    -u ver       Set Unifi version to build."
    echo "                 Defaults to ${DEFAULT_UNIFI_VERSION}"
    echo ""
}

# checkFileExists -- Confirm a file exists.
checkFileExists() {
    if [ -z $1 ]; then
        echo "checkFileExists: no argument passed."
        exit 1
    fi

    if [ ! -f $1 ]; then
        echo "FAIL: ${1} does not exist!"
        echo ""
        echo "Build terminated."
        exit 1
    fi
    echo "${1} exists."
}

# checkFileSignature -- Check file signature with GnuPG.
checkFileSignature() {
    if [ -z $1 ]; then
        echo "checkFileSignature: no argument passed."
        exit 1
    fi

    local filePath="${1}.asc"

    checkFileExists "$filePath"

    echo "Checking signature of artifact."
    echo "--- Begin: GnuPG Output ---------------------------------------------"

    gpg --verify "$filePath"
    local gpgExitStatus=$?

    echo "--- End: GnuPG Output -----------------------------------------------"

    if [ $gpgExitStatus -ne 0 ]; then
        echo "FAIL: Check of PGP signature failed. This is catastrophically bad"
        echo "and this script will exit. Possible causes include corruption of"
        echo "cached artifacts or a broken chain of trust in your GnuPG"
        echo "keyring. Check the output from GnuPG for clues."
        echo ""
        exit 2
    fi
}

# ------------------------------------------------------------------------------
# Handle command line arguments

BUILDER="${DEFAULT_BUILDER}"
BUILD_ARCH="${DEFAULT_BUILD_ARCH}"
CACHE_DIR="${DEFAULT_CACHE_DIR}"
DOCKER_FILE="${DEFAULT_DOCKER_FILE}"
NAME="${DEFAULT_NAME}"
UNIFI_VERSION="${DEFAULT_UNIFI_VERSION}"

while getopts "a:bc:df:hn:u:" opt; do
    case $opt in
        a)
            BUILD_ARCH="${OPTARG}"
            ;;
        b)
            BUILDER="buildah"
            ;;
        c)
            CACHE_DIR="${OPTARG}"
            ;;
        d)
            BUILDER="docker"
            ;;
        f)
            DOCKER_FILE="${OPTARG}"
            ;;
        h)
            printUsage
            exit
            ;;
        n)
            NAME="${OPTARG}"
            ;;
        u)
            UNIFI_VERSION="${OPTARG}"
            ;;
        *)
            echo "Script argument processing failed."
            exit 1
            ;;
    esac
done


# ------------------------------------------------------------------------------
# Calculated Variables

UNIFI_PKG_PATH=./cache/${UNIFI_VERSION}-UniFi.unix.zip 
IMAGE_TAG="${NAME}:${UNIFI_VERSION}"

BUILD_ARCH_LINE=""

if [ $BUILD_ARCH ]; then
    case $BUILDER in
        docker)
            BUILD_ARCH_LINE="--platform linux/${BUILD_ARCH}"
            ;;
        buildah)
            BUILD_ARCH_LINE="--arch ${BUILD_ARCH}"
            ;;
    esac

    IMAGE_TAG="${NAME}:${BUILD_ARCH}-${UNIFI_VERSION}"
fi


# ------------------------------------------------------------------------------
# 'Main'

echo ""
echo "=== Session Configuration ================================================"
echo "    BUILDER=${BUILDER}"
echo "    BUILD_ARCH=${BUILD_ARCH}"
echo "    CACHE_DIR=${CACHE_DIR}"
echo "    DOCKER_FILE=${DOCKER_FILE}"
echo "    NAME=${NAME}"
echo "    UNIFI_PKG_PATH=${UNIFI_PKG_PATH}"
echo "    UNIFI_VERSION=${UNIFI_VERSION}"
echo ""


echo "=== Performing Sanity Checks ============================================"

checkFileExists "${UNIFI_PKG_PATH}"


echo ""
echo "=== Perform Build ======================================================="
case $BUILDER in
    docker)
        docker build \
            --build-arg "UNIFI_VERSION=${UNIFI_VERSION}" \
            --build-arg "UNIFI_PKG_PATH=${UNIFI_PKG_PATH}" \
            $BUILD_ARCH_LINE \
            -t "$IMAGE_TAG" \
            -f "$DOCKER_FILE" .
        ;;
    buildah)
        buildah bud \
            --build-arg "UNIFI_VERSION=${UNIFI_VERSION}" \
            --build-arg "UNIFI_PKG_PATH=${UNIFI_PKG_PATH}" \
            $BUILD_ARCH_LINE \
            -t "$IMAGE_TAG" \
            -f "$DOCKER_FILE" .

        ;;
    *)
        echo "FAIL: Invalid builder ${BUILDER}."
        exit 1
        ;;
esac

echo "=== Build Complete ======================================================"
