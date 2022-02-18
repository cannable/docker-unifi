#!/bin/bash

# ------------------------------------------------------------------------------
# Unifi Controller - Install Script
# ------------------------------------------------------------------------------

# Sanity Checks
if [[ -z "$UNIFI_VERSION" ]]; then
    >&2 echo "You must define UNIFI_VERSION."
    exit 1
fi

if [[ -z "$UNIFI_PKG_URL" ]]; then
    >&2 echo "You must define UNIFI_PKG_URL."
    exit 1
fi


# Base deps
apt-get update

apt-get --no-install-recommends -y install \
	curl \
	openjdk-8-jre-headless \
	procps \
	less \
	nvi \
	gnupg


apt-get update


echo Downloading version ${UNIFI_VERSION} from ${UNIFI_PKG_URL}...
curl -o /data/unifi_sysvinit_all.deb "${UNIFI_PKG_URL}"
apt-get --no-install-recommends -y install /data/unifi_sysvinit_all.deb
rm -f /data/unifi_sysvinit_all.deb


echo Purging apt cache...
echo Ignore any cache error below this line.
apt-get -y clean
rm -rf /var/lib/apt/lists/*
