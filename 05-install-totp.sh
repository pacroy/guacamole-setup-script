#!/usr/bin/env bash
# TOTP Guacamole Extension Installation Script
# Description: Script to install TOTP authentication extensiton for Guacamole on Ubuntu Server 18.04.
# Author: Chairat Onyaem (Par)
# Source: https://github.com/pacroy/guacamole-setup-script
# References:
# - https://guacamole.apache.org/doc/gug/totp-auth.html
set -o errexit
set -o pipefail

# Variables
GUAC_VERSION="${GUAC_VERSION:-1.3.0}"

# Download and install TOTP extension
curl -fLO "https://downloads.apache.org/guacamole/${GUAC_VERSION}/binary/guacamole-auth-totp-${GUAC_VERSION}.tar.gz"
tar -xzf "guacamole-auth-totp-${GUAC_VERSION}.tar.gz"

sudo mkdir -p /etc/guacamole/extensions
sudo cp "guacamole-auth-totp-${GUAC_VERSION}/guacamole-auth-totp-${GUAC_VERSION}.jar" "/etc/guacamole/extensions/"

# Restart tomcat
sudo systemctl restart tomcat

# Clean up
rm -rf "guacamole-auth-totp-${GUAC_VERSION}"
rm -f "guacamole-auth-totp-${GUAC_VERSION}.tar.gz"
