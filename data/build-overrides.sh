#!/bin/bash

# ------------------------------------------------------------------------------
# Unifi Controller - Install Service Definitions
# ------------------------------------------------------------------------------

echo Applying build-time file overrides...
cp -R /data/overrides/root/* /
rm -rf /data/overrides

echo Done
