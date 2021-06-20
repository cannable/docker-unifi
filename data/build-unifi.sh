#!/bin/sh

# ------------------------------------------------------------------------------
# Unifi Controller - Install Script
# ------------------------------------------------------------------------------


# Base deps
apt-get update

apt-get --no-install-recommends -y install \
	curl \
	openjdk-8-jre-headless \
	procps \
	less \
	nvi \
	gnupg


# Mangled from https://help.ubnt.com/hc/en-us/articles/220066768-UniFi-How-to-Install-and-Update-via-APT-on-Debian-or-Ubuntu
echo 'deb http://www.ui.com/downloads/unifi/debian stable ubiquiti' > /etc/apt/sources.list.d/100-ubnt-unifi.list
curl -o /etc/apt/trusted.gpg.d/unifi-repo.gpg https://dl.ui.com/unifi/unifi-repo.gpg

apt-get update


# Install the Unifi Controller
if [[ -z "$UNIFI_VERSION" ]]; then
    echo No version specified, so using repo.
    apt-get --no-install-recommends -y install unifi
else
    url=https://dl.ui.com/unifi/${UNIFI_VERSION}/unifi_sysvinit_all.deb
    echo Downloading version ${UNIFI_VERSION}...
    curl -o /data/unifi_sysvinit_all.deb $url
    apt-get --no-install-recommends -y install /data/unifi_sysvinit_all.deb
    rm -f /data/unifi_sysvinit_all.deb
fi


echo Purging apt cache...
echo Ignore any cache error below this line.
apt-get -y clean
rm -rf /var/lib/apt/lists/*

