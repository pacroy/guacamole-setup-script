#!/usr/bin/env bash
# Guacamole Setup Script
# Description: Setup script to install and configure Apache Guacamole on Ubuntu Server 18.04. To be executed by a non-root, sudoer user.
# Author: Chairat Onyaem (Par)
# Source: https://github.com/pacroy/guacamole-setup-script
# References:
# - https://guacamole.apache.org/doc/gug/installing-guacamole.html
# - https://github.com/apache/guacamole-server/blob/master/Dockerfile
# - https://www.digitalocean.com/community/tutorials/how-to-install-apache-tomcat-8-on-ubuntu-16-04
# - https://certbot.eff.org/lets-encrypt/ubuntubionic-nginx
# - https://guacamole.apache.org/doc/gug/proxying-guacamole.html
set -o errexit
set -o pipefail

# Variables
GUAC_VERSION="1.3.0"
TOMCAT_VERSION="8.5.65"
DOMAIN_NAME="${DOMAIN_NAME:-${1}}"
EMAIL="${EMAIL:-${2}}"

if [ -z ${DOMAIN_NAME} ]; then >&2 echo "DOMAIN_NAME is required as an environment variable or as the 1st argument" && error=true; fi
if [ -z ${EMAIL} ]; then >&2 echo "EMAIL is required as an environment variable or as the 1st argument" && error=true; fi
if [ "$error" == "true" ]; then exit 90; fi

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

# Install nginx
sudo apt install --yes nginx-core

# Install certbot
sudo snap install core; sudo snap refresh core
sudo snap install --classic certbot

# Clean up
rm -rf snap

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

# Install Tomcat
TOMCAT_MAJOR_VERSION=$(echo ${TOMCAT_VERSION} | awk -F . '{print $1}')
sudo apt-get install --yes default-jdk
sudo groupadd tomcat
sudo useradd -s /bin/false -g tomcat -d /opt/tomcat tomcat
sudo adduser $USER tomcat
curl -LO "https://downloads.apache.org/tomcat/tomcat-${TOMCAT_MAJOR_VERSION}/v${TOMCAT_VERSION}/bin/apache-tomcat-${TOMCAT_VERSION}.tar.gz"
sudo mkdir /opt/tomcat
sudo tar xzvf "apache-tomcat-${TOMCAT_VERSION}.tar.gz" -C /opt/tomcat --strip-components=1
sudo chgrp -R tomcat /opt/tomcat
cd /opt/tomcat
sudo chmod -R g+r conf
sudo chmod g+x conf
sudo chown -R tomcat webapps/ work/ temp/ logs/

# Configure Tomcat service
JAVA_HOME=$(update-java-alternatives -l | awk '{print $3}')
echo "[Unit]
Description=Apache Tomcat Web Application Container
After=network.target

[Service]
Type=forking

Environment=JAVA_HOME=${JAVA_HOME}
Environment=CATALINA_PID=/opt/tomcat/temp/tomcat.pid
Environment=CATALINA_HOME=/opt/tomcat
Environment=CATALINA_BASE=/opt/tomcat
Environment='CATALINA_OPTS=-Xms512M -Xmx1024M -server -XX:+UseParallelGC'
Environment='JAVA_OPTS=-Djava.awt.headless=true -Djava.security.egd=file:/dev/./urandom'

ExecStart=/opt/tomcat/bin/startup.sh
ExecStop=/opt/tomcat/bin/shutdown.sh

User=tomcat
Group=tomcat
UMask=0007
RestartSec=10
Restart=always

[Install]
WantedBy=multi-user.target" | sudo tee /etc/systemd/system/tomcat.service > /dev/null
sudo systemctl daemon-reload
sudo systemctl start tomcat
systemctl status tomcat.service
sudo systemctl enable tomcat

# Clean up
cd ${OLDPWD}
rm -f "apache-tomcat-${TOMCAT_VERSION}.tar.gz"

# Download the client WAR and install
curl -LO "https://apache.org/dyn/closer.cgi?action=download&filename=guacamole/${GUAC_VERSION}/binary/guacamole-${GUAC_VERSION}.war"
sudo mv "guacamole-${GUAC_VERSION}.war" "/opt/tomcat/webapps/ROOT.war"
sudo chown tomcat:tomcat "/opt/tomcat/webapps/ROOT.war"
sudo systemctl restart tomcat

# Configure certbot
sudo certbot --nginx -d "${DOMAIN_NAME}" -m "${EMAIL}" --agree-tos -n

# Configure nginx
search_for='#\t\ttry_files $uri $uri\/ =404;'
replace_with='#'
sudo sed -i "s/${search_for}/${replace_with}/g" /etc/nginx/sites-enabled/default

search_for='# First attempt to serve request as file, then'
replace_with=''
sudo sed -i "s/${search_for}/${replace_with}/g" /etc/nginx/sites-enabled/default

search_for='# as directory, then fall back to displaying a 404.'
replace_with=''
sudo sed -i "s/${search_for}/${replace_with}/g" /etc/nginx/sites-enabled/default

search_for='try_files $uri $uri\/ =404;'
replace_with='proxy_pass http:\/\/localhost:8080\/;\
                proxy_buffering off;\
                proxy_http_version 1.1;\
                proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;\
                proxy_set_header Upgrade $http_upgrade;\
                proxy_set_header Connection $http_connection;\
                proxy_cookie_path \/guacamole\/ \/;\
                access_log off;'
sudo sed -i "s/${search_for}/${replace_with}/g" /etc/nginx/sites-enabled/default

sudo nginx -t
sudo systemctl restart nginx
