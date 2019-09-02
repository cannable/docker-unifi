#!/bin/sh

# ------------------------------------------------------------------------------
# Unifi Controller - Base Build Script
# ------------------------------------------------------------------------------

# Base deps
apt-get update
apt-get --no-install-recommends -y install \
	curl \
	openjdk-8-jre-headless \
	procps \
	less \
	gnupg
