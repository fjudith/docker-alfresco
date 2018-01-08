Alfresco Content Repository
===
[![](https://images.microbadger.com/badges/image/fjudith/alfresco-repository.svg)](https://microbadger.com/images/fjudith/alfresco-repository "Get your own image badge on microbadger.com")
[![Build Status](https://travis-ci.org/fjudith/docker-alfresco.svg?branch=master)](https://travis-ci.org/fjudith/docker-alfresco)

![high level architecture](https://raw.githubusercontent.com/fjudith/docker-alfresco/201707/alfresco_architecture.png)

# Supported tags and respective Dockerfile links

[`201707-repository`, `repository`](https://github.com/fjudith/docker-alfresco/tree/201707/repository)

## Description

Alfresco is a leading and modular Enterprise Content Management system providing document management, collaboration, web content services and record management.

This image is aims to run the core platform component **Alfresco Content Repository** as decated container.

## Roadmap

* [x] Implement option to disable CSRF
* [x] Support of LDAP authentication
* [x] Support of LDAP sync configuration
* [x] Support of Reverse-proxy configuration via environmnet variable
* [x] Database connection autoconf when using `--link` (supported aliases _mysql_, _postgres_)
* [x] Libreoffice connection using `--link` (supported alias _libreoffice_)
* [x] Solr Search Services connection using `--link` (supported alias _solr_)
* [x] Markdown Document support using `md-preview` add-on

## Default credentials

The default username and password are:
* username: **admin**
* password: **admin**

## Persistence

In production, volumes must be bind-mounted to the following directories to prevent data loss when removing the container.
Recommended approach is to point network share, especially in clustered environment (i.e Swarm, Kubernetes, Rancher, etc.)

| Path                                     | Description                                           |
| ---------------------------------------- | ----------------------------------------------------- |
| `/var/lib/alfresco/alf_data`             |                                                       |

## Environment variables

Below is the complete list of currently available parameters that can be set using environment variables.

### Database

Database connection can be configured using the following methods:

1. Manually using the following environment variables
2. Automatically by linking to a **PostgreSQL** or **MySQL** database container. 

| Name                | Description                                     | Default      |
| ------------------- | ----------------------------------------------- | ------------ |
| `DB_KIND`           | database type postgresql or mysql               | `postgresql` |
| `DB_USERNAME`       | username to use when connecting to the database | `alfresco`   |
| `DB_PASSWORD`       | password to use when connecting to the database | `admin`      |
| `DB_NAME`           | name of the database to connect to              | `alfresco`   |
| `DB_HOST`           | host of the database server                     | `postgres`   |
| `DB_CONN_PARAMS`    | database connection parameters                  | for MySQL, default = `?useSSL=false`, otherwise empty |

### Reverse-Proxy

The Reverse-Proxy url must begin with `http://`, or `https://` is SSL offloading is enabled on the device.

| Name                | Description                                     | Default      |
| ------------------- | ----------------------------------------------- | ------------ |
| `REVERSE_PROXY_URL` | url of the reverse-proxy                        | _empty_      |

### Host configuration

Host configuration mainly address the consistency of the links amended to the email notifications.

| Name                | Description                                     | Default      |
| ------------------- | ----------------------------------------------- | ------------ |
| `ALFRESCO_HOSTNAME` | hostname/fqdn of the Alfresco server            | `localhost`  |
| `ALFRESCO_PROTOCOL` | protocol of the Alfresco server                 | `http`       |
| `ALFRESCO_PORT`     | listen port of the Alfresco server              | `8080`       |
| `SHARE_HOSTNAME`    | hostname/fqdn of the Share server               | `localhost`  |
| `SHARE_PROTOCOL`    | protocol of the Share server                    | `http`       |
| `SHARE_PORT`        | listen port of the Share server                 | `8080`       |

### OpenOffice.org/LibreOffice services

LibreOffice container access specifications.

| Name                | Description                                     | Default      |
| ------------------- | ----------------------------------------------- | ------------ |
| `OOO_ENABLED`       | whether or not to enable documents rendering    | `true`       |
| `OOO_EXE`           | engine binary name                              | `http`       |
| `OOO_HOSTNAME`      | hostname/fqdn of the LibreOffice server         | `libreoffice` |
| `OOO_PORT`          | listen port of the Share server                 | `8100`       |

### Alfresco Search services (Solr)

Alfresco Search Services container access specifications.

| Name                   | Description                                     | Default      |
| ---------------------- | ----------------------------------------------- | ------------ |
| `SOLR_INDEX_SUBSYSTEM` | Solr index engine version                       | `solr6`      |
| `SOLR_HOST`            | hostname/fqdn of the Solr server                | `solr`       |
| `SOLR_PORT`            | listen port of the Solr server                  | `8983`       |
| `SOLR_PORT_SSL`        | secure channel listen port of the Solr server   | `8443`       |
| `SOLR_MAX_TOTAL`       | max simultaneous connections to Solr server     | `40`         |
| `SOLR_MAX_HOSTS`       | max simultaneous hosts connected to Solr server | `40`         |
| `SOLR_SECURECOMMS`     | whether or not to enable secure channel         | `false`      |
| `SOLR_BASE_URL`        | base url to solr service                        | `/solr`      |

### CIFS server

Allows to access the repository using the SMB/CIFS protocol (i.e Windows file sharing protocol).
CIFS domain and server name must be changed accordingly when combined to LDAP authentication.

| Name                | Description                                     | Default      |
| ------------------- | ----------------------------------------------- | ------------ |
| `CIFS_ENABLED`      | whether or not to enable CIFS                   | `true`       |
| `CIFS_SERVER_NAME`  | hostname of the CIFS server                     | `localhost`  |
| `CIFS_DOMAIN`       | domain of the CIFS server                       | `WORKGROUP`  |

### LDAP authentication

LDAP authentication is supported against most LDAP Controllers.

| Name                        | Description                                            | Default      |
| --------------------------- | ------------------------------------------------------ | ------------ |
| `LDAP_ENABLED`              | whether or not to enable LDAP                          | `false`      |
| `LDAP_URL`                  | URL of the LDAP server                                 | `ldap://ldap.example.com:389` |
| `LDAP_DEFAULT_ADMINS`       | comma separated list of alfresco admin names in ldap   | `admin` |
| `LDAP_GROUP_SEARCHBASE`     | path to retreive the authentication granted groups     | `cn=groups,cn=accounts,dc=example,dc=com` |
| `LDAP_USER_SEARCHBASE`      | path to retreive the authentication granted users      | `cn=users,cn=accounts,dc=example,dc=com`  |
| `LDAP_USER_SEARCHBASE`      | path to retreive the authentication granted users      | `cn=users,cn=accounts,dc=example,dc=com`  |
| `LDAP_TIMEOUT`              | ldap server connection timeout (milliseconds)          | `5000` |

_**Active Directory**_

The following example applies to Active Directory.

| Name                        | Description                                            | Default      |
| --------------------------- | ------------------------------------------------------ | ------------ |
| `LDAP_KIND`                 | ldap (e.g. for OpenLDAP) or ldap-ad (Active Directory) | `ldap-ad`    |
| `LDAP_AUTH_USERNAMEFORMAT`  | user authentication pattern                            | `%s@example.com` |
| `LDAP_SECURITY_PRINCIPAL`   | user dedicated to query the LDAP directory             | `admin@example.com` |
| `LDAP_SECURITY_CREDENTIALS` | password of the LDAP query user                        | `password`   |

_**LDAP Directory**_

The following example applies to other LDAP Directories.

| Name                        | Description                                            | Default      |
| --------------------------- | ------------------------------------------------------ | ------------ |
| `LDAP_KIND`                 | ldap (e.g. for OpenLDAP) or ldap-ad (Active Directory) | `ldap`       |
| `LDAP_AUTH_USERNAMEFORMAT`  | user authentication pattern                            | `uid=%s,cn=users,cn=accounts,dc=example,dc=com` |
| `LDAP_SECURITY_PRINCIPAL`   | user dedicated to query the LDAP directory             | `uid=admin,cn=users,cn=accounts,dc=example,dc=com` |
| `LDAP_SECURITY_CREDENTIALS` | password of the LDAP query user                        | `password`   |

### Synchronization

LDAP Synchronisation is only enabled if LDAP Authentication configured.

| Name                        | Description                                            | Default      |
| --------------------------- | ------------------------------------------------------ | ------------ |
| `SYNCHRONIZATION_SYNCHRONIZECHANGESONLY`     | Wether Full (false) or Differential (true) account synchronization    | `true`      |
| `SYNCHRONIZATION_ALLOWDELETIONS`             | Delete user from Alfresco if deleted from directory    | `true` |
| `SYNCHRONIZATION_IMPORT_CRON`                | Schedule of account synchronisation frequency   | `0 0/10 * * * *` (every 10 minutes) |
| `SYNCHRONIZATION_SYNCONSTARTUP`              | Trigger account synchronisation on Alfresco startup     | `true` |
| `SYNCHRONIZATION_SYNCWHENMISSINGPEOPLELOGIN` | Trigger a differential sync when a user, who does not yet exist, is successfully authenticated      | `true`  |
| `SYNCHRONIZATION_AUTOCREATEPEOPLEONLOGIN`    | Create a user with default properties when a user is successfully authenticated      | `true`  |

### Content storage directories

Content storage can be customized to enhance data segration.

| Name                        | Description                                            | Default      |
| --------------------------- | ------------------------------------------------------ | ------------ |
| `DIR_ROOT`                  | location of content store                              | `/var/lib/alfresco/alf_data` |
| `CONTENT_STORE`             | location of content store                              | `${dir.root}/contentstore` (/var/lib/alfresco/alf_data/contentstore) |
| `CONTENT_STORE_DELETED`     | location of deleted content store                      | `${dir.root}/contentstore` (/var/lib/alfresco/alf_data/contentstore.deleted) |
| `AMP_DIR_ALFRESCO`          | directory containing AMP files (modules) for alfresco.war | `ldap`       |
| `AMP_DIR_SHARE`             | directory containing AMP files (modules) for share.war    | `ldap`       |

### SMTP Gateway

SMTP-PLAIN (smtp), SMTP-SSL (smtps) and SMTP-STARTTLS methods are supported.

| Name                        | Description                                            | Default      |
| --------------------------- | ------------------------------------------------------ | ------------ |
| `MAIL_HOST`                 | hostname/fqdn of the SMTP server                       | `localhost`  | 
| `MAIL_PORT`                 | tcp listen port of the SMTP server                     | `25`         |
| `MAIL_PROTOCOL`             | smtp or smtps protocol                                 | `smtp`       | 
| `MAIL_ENCODING`             | message encoding                                       | `UTF-8`      | 
| `MAIL_FROM_DEFAULT_ENABLED` | enable email notification using default ip address     | `false`      | 
| `MAIL_FROM_DEFAULT`         | sender email address                                   | `alfresco@alfresco.org` |
| `MAIL_SMTP_USERNAME`        | user to connect the SMTP server                        |  _empty_     |
| `MAIL_SMTP_PASSWORD`        | password to connect the SMTP server                    |  _empty_     |
| `MAIL_SMTP_AUTH`            | enable smtp authentification                           |  `false`     |
| `MAIL_SMTP_STARTTLS`        | enable STARTTLS on smtp protocol (explicit ssl)        |  `false`     |
| `MAIL_SMTPS_AUTH`           | enable smtps authentification                          |  `false`     |
| `MAIL_SMTPS_STARTTLS_ENABLE` | enable STARTTLS on smtps protocol (implicit ssl)      |  `false`     |
| `MAIL_SMTP_TIMEOUT`         | email notification timeout (milliseconds)              |  `30000`     |
| `MAIL_SMTP_DEBUG`           | enable smtp notification debugging                     |  `false`     |

### SMTP startup test message

Unlock Alfresco capability to send an email notification once the engine successfully initialized.

| Name                        | Description                                            | Default      |
| --------------------------- | ------------------------------------------------------ | ------------ |
| `MAIL_TESTMESSAGE_SEND`     | enable smtp notification debugging                     | `false`      | 
| `MAIL_TESTMESSAGE_TO`       | startup notification receiver address                  | _empty_      | 
| `MAIL_TESTMESSAGE_SUBJECT`  | subject of the test message                            | `Alfresco - Service - Engine online` | 
| `MAIL_TESTMESSAGE_TEXT`     | subject of the test message                            | `Alfresco engine initialized and ready to accept connection` | 

_**Invitation notification**_

User receives an email notification once invited to a site.

| Name                        | Description                                            | Default      |
| --------------------------- | ------------------------------------------------------ | ------------ |
| `NOTIFICATION_EMAIL_SITEINVITE` | enable email notification to user on site invite   | `false`      |

## FTP server

Allows to access the repository using the FTP protocol.

| Name                        | Description                                            | Default      |
| --------------------------- | ------------------------------------------------------ | ------------ |
| `FTP_ENABLES`               | whether or not to enable CIFS                          | `false`      |
| `FTP_PORT`                  | port of the FTP server                                 | `21`         |

## NFS server

Allows to access the repository using the NFS protocol.

| Name                        | Description                                            | Default      |
| --------------------------- | ------------------------------------------------------ | ------------ |
| `NFS_ENABLED`               | whether or not to enable CIFS                          | `false`      |
| `NFS_PORT`                  | port of the FTP server                                 | `21`         |


### Build from Source

The source code is available at https://github.com/fjudith/alfresco.

Make sure your Docker host has more than 2 GB RAM available. Docker Hub uses 2 GB for automated builds which is not enough, the Alfresco installer will complain and fail. The Docker Toolbox VM also uses 2 GB by default, use VirtualBox to change it to at least 4GB.

```bash
git clone https://github.com/fjudith/alfresco.git
cd docker-alfresco
docker-compose build
```

### References

* http://www.alfresco.com/community
* http://docs.alfresco.com/community/concepts/welcome-infocenter_community.html
* https://addons.alfresco.com/addons/manual-manager-write-and-manage-documents-written-markdown
* https://addons.alfresco.com/addons/markdown-preview
