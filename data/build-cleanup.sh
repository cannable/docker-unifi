#!/bin/sh

# ------------------------------------------------------------------------------
# Unifi Controller - Build Cleanup Script
# ------------------------------------------------------------------------------


echo Purging apt cache...
echo Ignore any cache error below this line.
apt-get -y clean
rm -rf /var/lib/apt/lists/*
