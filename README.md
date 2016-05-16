[![Project Status: Inactive - The project has reached a stable, usable state but is no longer being actively developed; support/maintenance will be provided as time allows.](http://www.repostatus.org/badges/latest/inactive.svg)](http://www.repostatus.org/#inactive)

This is the README file for VBoxAdm.

## Description

VBoxAdm is a web based management GUI for Mailservers
running e.g. Postfix and Dovecot.

This repository contains all components of VBoxAdm
written in perl, including the webinterface, autoresponder,
content scanner and documentation.

## Docker

A set of Dockerfile and docker-compose.yml is provided on a best effort basis.
Please try to use the Docker to deploy this application as other options
won't be pursued any further.

IMPORTANT: If using the provided docker-compose.yml the environment
variables MYSQL_ROOT_PASSWORD and COOKIE_SECRET MUST NOT be left unchanged.

Initializing the Database is not yet covered by the Docker setup. Existing installations
may easily backup their existing database and restore it into the dockerized MariaDB.

The setup guide for new installations is not yet up to date. No ETA, sorry.

## See also

Please see the website of VBoxAdm at http://www.vboxadm.net/
for more information.

The Roundcube plugin can be found at
https://github.com/gittex/roundcube-plugin-vboxadm
