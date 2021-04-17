#!/usr/bin/env bash
set -o errexit
set -o pipefail

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
    libssl-dev \
    libvorbis-dev \
    libwebp-dev
