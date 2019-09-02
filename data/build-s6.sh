#!/bin/bash

# ------------------------------------------------------------------------------
# Unifi - Install s6-overlay
# ------------------------------------------------------------------------------

version=v1.21.8.0
url=https://github.com/just-containers/s6-overlay/releases/download/${version}/s6-overlay-amd64.tar.gz
filename=/tmp/s6-overlay-amd64.tar.gz

echo Installing s6-overlay...

curl -L -o "${filename}" "${url}"
curl -L -o "${filename}.sig" "${url}.sig"
curl https://keybase.io/justcontainers/key.asc | gpg --import

# Check the download signature
echo Checking tarball signature...
gpg --verify "${filename}.sig"

if [[ $? -ne 0 ]]; then
    (>&2 echo --------------------------------------------------)
    (>&2 echo --------------------------------------------------)
    (>&2 echo URGENT: $filename DOES NOT MATCH PGP SIGNATURE!)
    (>&2 echo IT WAS DOWNLOADED FROM ${url}.)
    (>&2 echo THIS IS NOT PARTICULARLY GOOD. CHECK YOUR DOWNLOAD.)
    (>&2 echo BUILD PROCESS TERMINATED. CONTAINER WILL NOT FUNCTION.)
    (>&2 echo --------------------------------------------------)
    (>&2 echo --------------------------------------------------)
    exit 1
fi

tar xpzf /tmp/s6-overlay-amd64.tar.gz -C /
rm -f /tmp/s6-overlay-amd64.tar.gz*

echo s6-overlay installed.