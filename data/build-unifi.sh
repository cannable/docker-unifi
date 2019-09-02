#!/bin/sh

# ------------------------------------------------------------------------------
# Unifi Controller - Install Script
# ------------------------------------------------------------------------------

# Install the Unifi Controller

# Mangled from https://help.ubnt.com/hc/en-us/articles/220066768-UniFi-How-to-Install-and-Update-via-APT-on-Debian-or-Ubuntu
echo 'deb http://www.ui.com/downloads/unifi/debian stable ubiquiti' > /etc/apt/sources.list.d/100-ubnt-unifi.list
curl -o /etc/apt/trusted.gpg.d/unifi-repo.gpg https://dl.ui.com/unifi/unifi-repo.gpg

apt-get update
apt-get --no-install-recommends -y install unifi
