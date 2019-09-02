#!/bin/sh

# ------------------------------------------------------------------------------
# Unifi Controller - Build All Script
# ------------------------------------------------------------------------------

# Source other build scripts (so as to minimize build layers)
source /data/build-base.sh
source /data/build-unifi.sh
source /data/build-s6.sh
source /data/build-cleanup.sh
