#!/bin/bash

# ------------------------------------------------------------------------------
# Unifi Controller - Install Service Definitions
# ------------------------------------------------------------------------------

echo Installing services...
cp -R /data/init/* /etc/services.d/
chown -R root:root /etc/services.d/*
chmod u+x /etc/services.d/unifi/*

echo Done
