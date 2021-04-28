#!/usr/bin/env bash
# MySQL for Guacamole Installation Script
# Description: Script to install MySQL DB and MySQL driver for Guacamole on Ubuntu Server 18.04.
# Author: Chairat Onyaem (Par)
# Source: https://github.com/pacroy/guacamole-setup-script
# References:
# - https://www.digitalocean.com/community/tutorials/how-to-install-mysql-on-ubuntu-18-04
# - https://guacamole.apache.org/doc/gug/jdbc-auth.html
# - https://vitux.com/7-methods-to-generate-a-strong-password-in-ubuntu/
set -o errexit
set -o pipefail

# Variables
GUAC_VERSION="${GUAC_VERSION:-1.3.0}"
CONNECTORJ_VERSION=${CONNECTORJ_VERSION:-8.0.24}

# Update & upgrade system
sudo apt-get update && sudo apt-get --yes upgrade

# Install MySQL
sudo apt install --yes mysql-server pwgen
systemctl status mysql --no-pager
sudo mysql --execute='select version()'

# Configure MySQL
# sudo mysql_secure_installation

# Download and install JDBC extensions
curl -fLO https://downloads.apache.org/guacamole/${GUAC_VERSION}/binary/guacamole-auth-jdbc-${GUAC_VERSION}.tar.gz
tar -xzf "guacamole-auth-jdbc-${GUAC_VERSION}.tar.gz"

sudo mkdir -p /etc/guacamole/extensions
sudo cp "guacamole-auth-jdbc-${GUAC_VERSION}/mysql/guacamole-auth-jdbc-mysql-${GUAC_VERSION}.jar" "/etc/guacamole/extensions/"

# Download and install MySQL Connector/J
curl -fLO "https://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-${CONNECTORJ_VERSION}.tar.gz"
tar -xvf "mysql-connector-java-${CONNECTORJ_VERSION}.tar.gz"

sudo mkdir -p /etc/guacamole/lib
sudo cp "mysql-connector-java-${CONNECTORJ_VERSION}/mysql-connector-java-${CONNECTORJ_VERSION}.jar" "/etc/guacamole/lib/"

# Configure MySQL database
MYSQL_PASSWORD=${MYSQL_PASSWORD:-$(pwgen -ys 16 1)}
sudo mysql --execute='CREATE DATABASE guacamole_db;'
sudo mysql --execute="CREATE USER 'guacamole_user'@'localhost' IDENTIFIED BY '${MYSQL_PASSWORD}';"
sudo mysql --execute="GRANT SELECT,INSERT,UPDATE,DELETE ON guacamole_db.* TO 'guacamole_user'@'localhost';"
sudo mysql --execute='FLUSH PRIVILEGES;'

# Configure schema and default user
cat guacamole-auth-jdbc-1.3.0/mysql/schema/*.sql | sudo mysql guacamole_db

# Configure MySQL connection for Guacamole client
echo '# MySQL properties
mysql-hostname: localhost
mysql-port: 3306
mysql-database: guacamole_db
mysql-username: guacamole_user'"
mysql-password: ${MYSQL_PASSWORD}" | sudo tee /etc/guacamole/guacamole.properties

# Remove user-mapping file
sudo rm -f /etc/guacamole/user-mapping.xml

# Restart tomcat
sudo systemctl restart tomcat

# Clean up
rm -rf "guacamole-auth-jdbc-${GUAC_VERSION}"
rm "guacamole-auth-jdbc-${GUAC_VERSION}.tar.gz"
rm -rf "mysql-connector-java-${CONNECTORJ_VERSION}"
rm "mysql-connector-java-${CONNECTORJ_VERSION}.tar.gz"
