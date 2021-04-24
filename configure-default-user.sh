#!/usr/bin/env bash
# Configure default user for Guacamole client
# Description: Script to configure default user `guacadmin` in user-mapping.xml
# Author: Chairat Onyaem (Par)
# Source: https://github.com/pacroy/guacamole-setup-script
# References:
# - https://guacamole.apache.org/doc/gug/configuring-guacamole.html
set -o errexit
set -o pipefail

# Configure default user
sudo mkdir -p /etc/guacamole
echo '<user-mapping>
    <authorize username="guacadmin" password="guacadmin">
        <connection name="this-server-ssh">
             <protocol>ssh</protocol>
             <param name="hostname">localhost</param>
             <param name="port">22</param>
        </connection>
        <connection name="some-win10-rdp">
             <protocol>rdp</protocol>
             <param name="hostname">some-win10-rdp</param>
             <param name="port">3389</param>
             <param name="username">username</param>
             <param name="password">thisisyourpassword</param>
             <param name="ignore-cert">true</param>
        </connection>
    </authorize>
</user-mapping>' | sudo tee /etc/guacamole/user-mapping.xml
sudo systemctl restart tomcat
