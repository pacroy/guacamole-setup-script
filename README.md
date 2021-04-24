# Guacamole Setup Scripts

Shell scripts for install Apache Guacamole on Ubuntu Server 18.04

## Prerequisites
- A fresh Install of Ubuntu Server 18.04 (It may work on other versions but I haven't tested)
- A public FQDN pointing to your server

## Usage

### Install Guacamole Server and Client

Run script as non-root, sudoer user.

```sh
DOMAIN_NAME=<Your Server FQDN>
EMAIL=<Your Email Address>
./setup.sh
```

Or you can execute scripts manually

```sh
DOMAIN_NAME=<Your Server FQDN>
EMAIL=<Your Email Address>
./01-install-server.sh  # Install Guacamole server
./02-install-client.sh  # Install Guacamole client
./03-configure-user.sh  # Configure basic user in user-mapping.xml
```

Test Guacamole by openning `https://<Your Server FQDN>` and log in using `guacadmin` as username and password and you should see two dummy connections there. This means eveything is setup and running but you cannot change anything on the web interface because of lacking of database. Proceed the next section.

### Install MySQL Database

Install MySQL database by executing the next script.

```sh
./04-install-mysql.sh
```

Log in again using `guacadmin` as username and password. Now, you should create a new user with admin permissions and delete the `guacadmin` account for security reasons.

### Enable Two-Factor Authentication

You can optionally enable two-factor authentication by execute the next script.

```sh
./04-install-mysql.sh
```

## Troubleshooting

### Guacamole Client Logs

Log in to your server and execute this command.

```sh
tail -f /opt/tomcat/logs/catalina.out
```

### Guacamole Server Logs

Log in to your server and execute this command.

```sh
journalctl -fu guacd.service
```

You may need to increase log level to DEBUG for more information. See guacd --help for more information.
