#!/usr/bin/env bash
set -o errexit
set -o pipefail

# Variables
GUAC_VERSION="1.3.0"
TOMCAT_VERSION="8.5.65"

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

# Clean up
cd ${OLDPWD}

# Install Tomcat
sudo apt-get install --yes default-jdk
sudo groupadd tomcat
sudo useradd -s /bin/false -g tomcat -d /opt/tomcat tomcat
curl -LO "https://downloads.apache.org/tomcat/tomcat-8/v${TOMCAT_VERSION}/bin/apache-tomcat-${TOMCAT_VERSION}.tar.gz"
sudo mkdir /opt/tomcat
sudo tar xzvf "apache-tomcat-${TOMCAT_VERSION}.tar.gz" -C /opt/tomcat --strip-components=1
sudo chgrp -R tomcat /opt/tomcat
cd /opt/tomcat
sudo chmod -R g+r conf
sudo chmod g+x conf
sudo chown -R tomcat webapps/ work/ temp/ logs/

# Clean up
cd ${OLDPWD}
