#!/usr/bin/env bash
# Guacamole Setup Script
# Description: Setup script to install and configure Apache Guacamole on Ubuntu Server 18.04. To be executed by a non-root, sudoer user.
# Author: Chairat Onyaem (Par)
# Source: https://github.com/pacroy/guacamole-setup-script
set -o errexit
set -o pipefail

# Variables
export GUAC_VERSION="${GUAC_VERSION:-1.3.0}"
export TOMCAT_VERSION="${TOMCAT_VERSION:-8.5.65}"
export DOMAIN_NAME="${DOMAIN_NAME:-${1}}"
export EMAIL="${EMAIL:-${2}}"

if [ -z ${DOMAIN_NAME} ]; then >&2 echo "DOMAIN_NAME is required as an environment variable or as the 1st argument" && error=true; fi
if [ -z ${EMAIL} ]; then >&2 echo "EMAIL is required as an environment variable or as the 1st argument" && error=true; fi
if [ "$error" == "true" ]; then exit 90; fi

./01-install-server.sh
./02-install-client.sh
./03-configure-user.sh
