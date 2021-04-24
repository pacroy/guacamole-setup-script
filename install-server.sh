#!/usr/bin/env bash
# Guacamole Server Installation Script
# Description: Script to install Apache Guacamole server on Ubuntu Server 18.04.
# Author: Chairat Onyaem (Par)
# Source: https://github.com/pacroy/guacamole-setup-script
# References:
# - https://guacamole.apache.org/doc/gug/installing-guacamole.html
# - https://github.com/apache/guacamole-server/blob/master/Dockerfile
set -o errexit
set -o pipefail

# Variables
GUAC_VERSION="${GUAC_VERSION:-1.3.0}"

# Update & upgrade system
sudo apt-get update && sudo apt-get --yes upgrade

# Install build tools
sudo apt install --yes build-essential

# Install build dependencies
sudo apt install --yes libcairo2-dev libjpeg-turbo8-dev libpng-dev libtool-bin libossp-uuid-dev

# Install optional dependencies
sudo apt install --yes \	
    libavcodec-dev libavformat-dev libavutil-dev libswscale-dev \
    freerdp2-dev \
    libpango1.0-dev \
    libssh2-1-dev \
    libtelnet-dev \
    libvncserver-dev \
    libwebsockets-dev \
    libpulse-dev \
    libssl-dev \
    libvorbis-dev \
    libwebp-dev

# Install runtime dependencies
sudo apt install --yes --no-install-recommends \	
    netcat-openbsd                \
    ca-certificates               \
    ghostscript                   \
    fonts-liberation              \
    fonts-dejavu                  \
    xfonts-terminus

# Download the server and extract
curl -fO "https://downloads.apache.org/guacamole/${GUAC_VERSION}/source/guacamole-server-${GUAC_VERSION}.tar.gz"
tar -xzf "guacamole-server-${GUAC_VERSION}.tar.gz"

# Configure build
cd "guacamole-server-${GUAC_VERSION}"
./configure --with-init-dir=/etc/init.d

# Build and install
make
sudo make install
sudo ldconfig

# Start service
sudo systemctl start guacd
systemctl status guacd
sudo systemctl enable guacd

# Clean up
cd ${OLDPWD}
rm -rf "guacamole-server-${GUAC_VERSION}"
rm -f "guacamole-server-${GUAC_VERSION}.tar.gz"
