#!/bin/bash
CATALINA_HOME='/usr/local/tomcat'
ALF_HOME="${CATALINA_HOME}/webapps/alfresco"
ALF_BIN="${ALF_HOME}/bin"
ALF_SETUP="${ALF_HOME}/setup"
DIR_ROOT=${DIR_ROOT:-'/var/lib/alfresco/alf_data'}
CONTENT_STORE=${CONTENT_STORE:-'${dir.root}/contentstore'}
CONTENT_STORE_DELETED=${CONTENT_STORE_DELETED:-'${dir.root}/contentstore.deleted'}
IMG_ROOT=${IMG_ROOT:-'/usr'}
ALFRESCO_PDF_RENDERER_ROOT=${ALFRESCO_PDF_RENDERER_ROOT:-'/usr/local/bin'}

ALFRESCO_HOSTNAME=${ALFRESCO_HOSTNAME:-127.0.0.1}
ALFRESCO_PROTOCOL=${ALFRESCO_PROTOCOL:-http}
ALFRESCO_PORT=${ALFRESCO_PORT:-8080}

SHARE_HOSTNAME=${SHARE_HOSTNAME:-127.0.0.1}
SHARE_PROTOCOL=${SHARE_PROTOCOL:-http}
SHARE_PORT=${SHARE_PORT:-8080}

# if we're linked to MySQL and thus have credentials already, let's use them
if [[ -v MYSQL_ENV_GOSU_VERSION ]]; then
    DB_KIND='mysql'
    DB_HOST='mysql'
    DB_USERNAME=${MYSQL_ENV_MYSQL_USER:-root}
    if [ "$DB_USERNAME" = 'root' ]; then
        DB_PASSWORD=${MYSQL_ENV_MYSQL_ROOT_PASSWORD}
    fi
    DB_PASSWORD=${MYSQL_ENV_MYSQL_PASSWORD}
    DB_NAME=${MYSQL_ENV_MYSQL_DATABASE:-alfresco}
    DB_URL="jdbc:mysql://mysql:3306/$DB_NAME"

    echo 'Using MysQL'
    DB_DRIVER='org.gjt.mm.mysql.Driver'
    DB_PORT='3306'
    DB_CONN_PARAMS=${DB_CONN_PARAMS:-'?useSSL=false'}

    if [ -z "$DB_PASSWORD" ]; then
        echo >&2 'error: missing required DB_PASSWORD environment variable'
        echo >&2 '  Did you forget to -e DB_PASSWORD=... ?'
        echo >&2
        echo >&2 '  (Also of interest might be DB_USERNAME and DB_NAME.)'
        exit 1
    fi
fi

# if we're linked to PostgreSQL and thus have credentials already, let's use them
if [[ -v POSTGRES_ENV_GOSU_VERSION ]]; then
    DB_KIND='postgresql'
    DB_HOST='postgres'
    DB_USERNAME=${POSTGRES_ENV_POSTGRES_USER:-root}
    if [ "$DB_USERNAME" = 'postgres' ]; then
        DB_PASSWORD='postgres'
    fi
    DB_PASSWORD=${POSTGRES_ENV_POSTGRES_PASSWORD}
    DB_NAME=${POSTGRES_ENV_POSTGRES_DB:-alfresco}
    DB_URL="jdbc:postgresql://postgres:5432/$DB_NAME"

    echo 'Using PostgreSQL'
    DB_DRIVER='org.postgresql.Driver'
    DB_PORT='5432'

    if [ -z "$DB_PASSWORD" ]; then
        echo >&2 'error: missing required DB_PASSWORD environment variable'
        echo >&2 '  Did you forget to -e DB_PASSWORD=... ?'
        echo >&2
        echo >&2 '  (Also of interest might be DB_USERNAME and DB_NAME.)'
        exit 1
    fi
fi

DB_KIND=${DB_KIND:-'postgresql'}
DB_DRIVER=${DB_DRIVER:-'org.postgresql.Driver'}
DB_PORT=${DB_PORT:-'5432'}
DB_USERNAME=${DB_USERNAME:-'alfresco'}
DB_PASSWORD=${DB_PASSWORD:-'admin'}   
DB_NAME=${DB_NAME:-'alfresco'}
DB_HOST=${DB_HOST:-'localhost'}

if [ "$DB_KIND" == "mysql" ]; then
    DB_DRIVER='org.gjt.mm.mysql.Driver'
    DB_PORT=${DB_PORT:-'3306'}
    DB_CONN_PARAMS=${DB_CONN_PARAMS:-'?useSSL=false'}
fi

SYSTEM_SERVERMODE=${SYSTEM_SERVERMODE:-'PRODUCTION'}

MAIL_HOST=${MAIL_HOST:-'localhost'}
MAIL_PORT=${MAIL_PORT:-'25'}
MAIL_SMTP_USERNAME=${MAIL_SMTP_USERNAME:-'alfresco'}
MAIL_SMTP_PASSWORD=${MAIL_SMTP_PASSWORD:-'password'}
MAIL_FROM_DEFAULT=${MAIL_FROM_DEFAULT:-'alfresco@alfresco.org'}
MAIL_PROTOCOL=${MAIL_PROTOCOL:-'smtp'}
MAIL_SMTP_AUTH=${MAIL_SMTP_AUTH:-'false'}
MAIL_SMTP_STARTTLS=${MAIL_SMTP_STARTTLS:-'false'}
MAIL_SMTPS_AUTH=${MAIL_SMTPS_AUTH:-'false'}
MAIL_SMTPS_STARTTLS_ENABLE=${MAIL_SMTPS_STARTTLS_ENABLE:-'false'}
MAIL_FROM_DEFAULT_ENABLED=${MAIL_FROM_DEFAULT_ENABLED:-'false'}
MAIL_ENCODING=${MAIL_ENCODING:-'UTF-8'}
MAIL_SMTP_TIMEOUT=${MAIL_SMTP_TIMEOUT:-'30000'}
MAIL_SMTP_DEBUG=${MAIL_SMTP_DEBUG:-'false'}

MAIL_TESTMESSAGE_SEND=${MAIL_TESTMESSAGE_SEND:-'false'}
MAIL_TESTMESSAGE_TO=${MAIL_TESTMESSAGE_TO:-}
MAIL_TESTMESSAGE_SUBJECT=${MAIL_TESTMESSAGE_SUBJECT:-"Alfresco - Service - Engine online"}
MAIL_TESTMESSAGE_TEXT=${MAIL_TESTMESSAGE_TEXT:-"Alfresco engine initialized and ready to accept connection"}

NOTIFICATION_EMAIL_SITEINVITE=${NOTIFICATION_EMAIL_SITEINVITE:-'false'}

FTP_ENABLED=${FTP_ENABLED:-'false'}
FTP_PORT=${FTP_PORT:-'21'}

CIFS_ENABLED=${CIFS_ENABLED:-'true'}
CIFS_SERVER_NAME=${CIFS_SERVER_NAME:-'localhost'}
CIFS_DOMAIN=${CIFS_DOMAIN:-'WORKGROUP'}

LDAP_ENABLED=${LDAP_ENABLED:-'false'}
LDAP_KIND=${LDAP_KIND:-'ldap'}
LDAP_AUTH_USERNAMEFORMAT=${LDAP_AUTH_USERNAMEFORMAT:-'uid=%s,cn=users,cn=accounts,dc=example,dc=com'}
LDAP_URL=${LDAP_URL:-ldap://ldap.example.com:'389'}
LDAP_DEFAULT_ADMINS=${LDAP_DEFAULT_ADMINS:-'admin'}
LDAP_SECURITY_PRINCIPAL=${LDAP_SECURITY_PRINCIPAL:-'uid=admin,cn=users,cn=accounts,dc=example,dc=com'}
LDAP_SECURITY_CREDENTIALS=${LDAP_SECURITY_CREDENTIALS:-'password'}
LDAP_GROUP_SEARCHBASE=${LDAP_GROUP_SEARCHBASE:-'cn=groups,cn=accounts,dc=example,dc=com'}
LDAP_USER_SEARCHBASE=${LDAP_USER_SEARCHBASE:-'cn=users,cn=accounts,dc=example,dc=com'}
LDAP_TIMEOUT=${LDAP_TIMEOUT:-5000}

REVERSE_PROXY_URL=${REVERSE_PROXY_URL:-}

OOO_ENABLED=${OOO_ENABLED:-'true'}
OOO_EXE=${OOO_EXE:-'soffice'}
OOO_HOST=${OOO_HOST:-'libreoffice'}
OOO_PORT=${OOO_PORT:-'8100'}

SOLR_INDEX_SUBSYSTEM=${SOLR_INDEX_SUBSYSTEM:-'solr6'}
SOLR_HOST=${SOLR_HOST:-'solr'}
SOLR_PORT=${SOLR_PORT:-'8983'}
SOLR_PORT_SSL=${SOLR_PORT_SSL:-'8443'}
SOLR_MAX_TOTAL=${SOLR_MAX_TOTAL:-'40'}
SOLR_MAX_HOSTS=${SOLR_MAX_HOSTS:-'40'}
SOLR_SECURECOMMS=${SOLR_SECURECOMMS:-'none'}
SOLR_BASE_URL=${SOLR_BASE_URL:-'/solr'}


SYNCHRONIZATION_SYNCHRONIZECHANGESONLY=${SYNCHRONIZATION_SYNCHRONIZECHANGESONLY:-'true'}
SYNCHRONIZATION_ALLOWDELETIONS=${SYNCHRONIZATION_ALLOWDELETIONS:-'true'}
SYNCHRONIZATION_IMPORT_CRON=${SYNCHRONIZATION_IMPORT_CRON:-'0 0/10 * * * *'}
SYNCHRONIZATION_SYNCONSTARTUP=${SYNCHRONIZATION_SYNCONSTARTUP:-'true'}
SYNCHRONIZATION_SYNCWHENMISSINGPEOPLELOGIN=${SYNCHRONIZATION_SYNCWHENMISSINGPEOPLELOGIN:-'true'}
SYNCHRONIZATION_AUTOCREATEPEOPLEONLOGIN=${SYNCHRONIZATION_AUTOCREATEPEOPLEONLOGIN:-'true'}

SMART_FOLDERS_ENABLED=${SMART_FOLDERS_ENABLED:-'false'} 

function cfg_replace_option {
  grep "$1" "$3" > /dev/null
  if [ $? -eq 0 ]; then
    # replace option
    echo "replacing option  $1=$2  in  $3"
    sed -i "s#^\($1\s*=\s*\).*\$#\1$2#" $3
    if (( $? )); then
      echo "cfg_replace_option failed"
      exit 1
    fi
  else
    # add option if it does not exist
    echo "adding option  $1=$2  in  $3"
    echo "$1=$2" >> $3
  fi
}

function tweak_alfresco {
  ALFRESCO_GLOBAL_PROPERTIES=$CATALINA_HOME/webapps/alfresco/WEB-INF/classes/alfresco-global.properties
  
  echo -e "\n### Settings added by init script" >> $ALFRESCO_GLOBAL_PROPERTIES

  cfg_replace_option alfresco.host $ALFRESCO_HOSTNAME $ALFRESCO_GLOBAL_PROPERTIES
  cfg_replace_option alfresco.protocol $ALFRESCO_PROTOCOL $ALFRESCO_GLOBAL_PROPERTIES
  cfg_replace_option alfresco.port $ALFRESCO_PORT $ALFRESCO_GLOBAL_PROPERTIES
  cfg_replace_option share.host $SHARE_HOSTNAME $ALFRESCO_GLOBAL_PROPERTIES
  cfg_replace_option share.protocol $SHARE_PROTOCOL $ALFRESCO_GLOBAL_PROPERTIES
  cfg_replace_option share.port $SHARE_PORT $ALFRESCO_GLOBAL_PROPERTIES

  # db.schema.update=true
  cfg_replace_option db.driver $DB_DRIVER $ALFRESCO_GLOBAL_PROPERTIES
  cfg_replace_option db.username $DB_USERNAME $ALFRESCO_GLOBAL_PROPERTIES
  cfg_replace_option db.password $DB_PASSWORD $ALFRESCO_GLOBAL_PROPERTIES
  cfg_replace_option db.name $DB_NAME $ALFRESCO_GLOBAL_PROPERTIES
  cfg_replace_option db.url "jdbc:${DB_KIND,,}://${DB_HOST}:${DB_PORT}/${DB_NAME}${DB_CONN_PARAMS}" $ALFRESCO_GLOBAL_PROPERTIES

  cfg_replace_option ftp.enabled $FTP_ENABLED $ALFRESCO_GLOBAL_PROPERTIES
  cfg_replace_option ftp.port $FTP_PORT $ALFRESCO_GLOBAL_PROPERTIES

  # libreoffice
  cfg_replace_option ooo.enabled $OOO_ENABLED $ALFRESCO_GLOBAL_PROPERTIES
  cfg_replace_option ooo.exe $OOO_EXE $ALFRESCO_GLOBAL_PROPERTIES
  cfg_replace_option ooo.host $OOO_HOST $ALFRESCO_GLOBAL_PROPERTIES
  cfg_replace_option ooo.port $OOO_PORT $ALFRESCO_GLOBAL_PROPERTIES

  # Solr
  cfg_replace_option index.subsystem.name $SOLR_INDEX_SUBSYSTEM $ALFRESCO_GLOBAL_PROPERTIES
  cfg_replace_option solr.host $SOLR_HOST $ALFRESCO_GLOBAL_PROPERTIES
  cfg_replace_option solr.port $SOLR_PORT $ALFRESCO_GLOBAL_PROPERTIES
  cfg_replace_option solr.port.ssl $SOLR_PORT_SSL $ALFRESCO_GLOBAL_PROPERTIES
  cfg_replace_option solr.max.total.connections $SOLR_MAX_TOTAL $ALFRESCO_GLOBAL_PROPERTIES
  cfg_replace_option solr.max.host.connections $SOLR_MAX_HOSTS $ALFRESCO_GLOBAL_PROPERTIES
  cfg_replace_option solr.secureComms $SOLR_SECURECOMMS $ALFRESCO_GLOBAL_PROPERTIES
  cfg_replace_option solr.baseUrl $SOLR_BASE_URL $ALFRESCO_GLOBAL_PROPERTIES

  # @see https://forums.alfresco.com/en/viewtopic.php?f=8&t=20893
  # CIFS works, but you have to login as a native Alfresco account, like admin
  # because CIFS does not work with LDAP authentication
  cfg_replace_option cifs.enabled $CIFS_ENABLED $ALFRESCO_GLOBAL_PROPERTIES
  cfg_replace_option cifs.Server.Name $CIFS_SERVER_NAME $ALFRESCO_GLOBAL_PROPERTIES
  cfg_replace_option cifs.domain $CIFS_DOMAIN $ALFRESCO_GLOBAL_PROPERTIES
  cfg_replace_option cifs.hostannounce "true" $ALFRESCO_GLOBAL_PROPERTIES
  cfg_replace_option cifs.broadcast "0.0.0.255" $ALFRESCO_GLOBAL_PROPERTIES
  cfg_replace_option cifs.ipv6.enabled "false" $ALFRESCO_GLOBAL_PROPERTIES


  # MAIL/SMTP Configuration
  # https://wiki.alfresco.com/wiki/Outbound_E-mail_Configuration
  cfg_replace_option mail.host $MAIL_HOST $ALFRESCO_GLOBAL_PROPERTIES
  cfg_replace_option mail.port $MAIL_PORT $ALFRESCO_GLOBAL_PROPERTIES
  cfg_replace_option mail.username $MAIL_SMTP_USERNAME $ALFRESCO_GLOBAL_PROPERTIES
  cfg_replace_option mail.password $MAIL_SMTP_PASSWORD $ALFRESCO_GLOBAL_PROPERTIES
  cfg_replace_option mail.from.default $MAIL_FROM_DEFAULT $ALFRESCO_GLOBAL_PROPERTIES
  cfg_replace_option mail.from.enabled $MAIL_FROM_DEFAULT_ENABLED $ALFRESCO_GLOBAL_PROPERTIES
  cfg_replace_option mail.encoding $MAIL_ENCODING $ALFRESCO_GLOBAL_PROPERTIES
  cfg_replace_option mail.smtp.timeout $MAIL_SMTP_TIMEOUT $ALFRESCO_GLOBAL_PROPERTIES
  cfg_replace_option mail.smtp.debug $MAIL_SMTP_DEBUG $ALFRESCO_GLOBAL_PROPERTIES
  cfg_replace_option mail.protocol $MAIL_PROTOCOL $ALFRESCO_GLOBAL_PROPERTIES
  cfg_replace_option mail.smtp.auth $MAIL_SMTP_AUTH $ALFRESCO_GLOBAL_PROPERTIES
  cfg_replace_option mail.smtp.starttls.enable $MAIL_SMTP_STARTTLS $ALFRESCO_GLOBAL_PROPERTIES
  cfg_replace_option mail.smtps.auth $MAIL_SMTPS_AUTH $ALFRESCO_GLOBAL_PROPERTIES
  cfg_replace_option mail.smtps.starttls.enable $MAIL_SMTPS_STARTTLS_ENABLE $ALFRESCO_GLOBAL_PROPERTIES

  cfg_replace_option mail.testmessage.send $MAIL_TESTMESSAGE_SEND $ALFRESCO_GLOBAL_PROPERTIES
  cfg_replace_option mail.testmessage.to $MAIL_TESTMESSAGE_TO $ALFRESCO_GLOBAL_PROPERTIES
  cfg_replace_option mail.testmessage.subject "$MAIL_TESTMESSAGE_SUBJECT" $ALFRESCO_GLOBAL_PROPERTIES
  cfg_replace_option mail.testmessage.text "$MAIL_TESTMESSAGE_TEXT" $ALFRESCO_GLOBAL_PROPERTIES

  cfg_replace_option notification.email.siteinvite $NOTIFICATION_EMAIL_SITEINVITE $ALFRESCO_GLOBAL_PROPERTIES

  # authentication
  if [ "$LDAP_ENABLED" == "true" ]; then
    cfg_replace_option authentication.chain "alfrescoNtlm1:alfrescoNtlm,ldap1:${LDAP_KIND}" $ALFRESCO_GLOBAL_PROPERTIES

    # now make substitutions in the LDAP config file
    LDAP_CONFIG_FILE=$CATALINA_HOME/shared/classes/alfresco/extension/subsystems/Authentication/${LDAP_KIND}/ldap1/${LDAP_KIND}-authentication.properties

    cfg_replace_option ldap.authentication.userNameFormat $LDAP_AUTH_USERNAMEFORMAT $LDAP_CONFIG_FILE
    cfg_replace_option ldap.authentication.java.naming.provider.url "$LDAP_URL" $LDAP_CONFIG_FILE
    cfg_replace_option ldap.authentication.defaultAdministratorUserNames $LDAP_DEFAULT_ADMINS $LDAP_CONFIG_FILE
    cfg_replace_option ldap.synchronization.java.naming.security.principal $LDAP_SECURITY_PRINCIPAL $LDAP_CONFIG_FILE
    cfg_replace_option ldap.synchronization.java.naming.security.credentials $LDAP_SECURITY_CREDENTIALS $LDAP_CONFIG_FILE
    cfg_replace_option ldap.synchronization.groupSearchBase $LDAP_GROUP_SEARCHBASE $LDAP_CONFIG_FILE
    cfg_replace_option ldap.synchronization.userSearchBase $LDAP_USER_SEARCHBASE $LDAP_CONFIG_FILE
    cfg_replace_option ldap.authentication.java.naming.read.timeout $LDAP_TIMEOUT $LDAP_CONFIG_FILE
  else
    cfg_replace_option authentication.chain "alfrescoNtlm1:alfrescoNtlm" $ALFRESCO_GLOBAL_PROPERTIES
  fi

  # Synchronization
  if [ "$LDAP_ENABLED" == "true" ]; then
    cfg_replace_option synchronization.synchronizeChangesOnly $SYNCHRONIZATION_SYNCHRONIZECHANGESONLY $ALFRESCO_GLOBAL_PROPERTIES
    cfg_replace_option synchronization.allowDeletions $SYNCHRONIZATION_ALLOWDELETIONS $ALFRESCO_GLOBAL_PROPERTIES
    cfg_replace_option synchronization.import.cron "$SYNCHRONIZATION_IMPORT_CRON" $ALFRESCO_GLOBAL_PROPERTIES
    cfg_replace_option synchronization.syncOnStartup $SYNCHRONIZATION_SYNCONSTARTUP $ALFRESCO_GLOBAL_PROPERTIES
    cfg_replace_option synchronization.syncWhenMissingPeopleLogIn $SYNCHRONIZATION_SYNCWHENMISSINGPEOPLELOGIN $ALFRESCO_GLOBAL_PROPERTIES
    cfg_replace_option synchronization.autoCreatePeopleOnLogin $SYNCHRONIZATION_AUTOCREATEPEOPLEONLOGIN $ALFRESCO_GLOBAL_PROPERTIES
  fi

  # content store
  if [ ! -d ${DIR_ROOT} ]; then mkdir -p ${DIR_ROOT}; fi

  cfg_replace_option dir.root "${DIR_ROOT}" $ALFRESCO_GLOBAL_PROPERTIES
  cfg_replace_option dir.contentstore "${CONTENT_STORE}" $ALFRESCO_GLOBAL_PROPERTIES
  cfg_replace_option dir.contentstore.deleted "${CONTENT_STORE_DELETED}" $ALFRESCO_GLOBAL_PROPERTIES
  
  # Binaries
  cfg_replace_option img.root "${IMG_ROOT}" $ALFRESCO_GLOBAL_PROPERTIES
  cfg_replace_option alfresco-pdf-renderer.root "${ALFRESCO_PDF_RENDERER_ROOT}" $ALFRESCO_GLOBAL_PROPERTIES

  # smartfolder
  cfg_replace_option smart.folders.enabled ${SMART_FOLDERS_ENABLED} $ALFRESCO_GLOBAL_PROPERTIES
}

function set_reverse_proxy {
  if [ -z $REVERSE_PROXY_URL ]; then
    echo "INFO: Reverse proxy not configured"
  else
    echo "INFO: Configuring alfresco for independant reverse-proxy support"
    # Alfresco Open CMIS URL rewrite
    cfg_replace_option opencmis.context.override true $ALFRESCO_GLOBAL_PROPERTIES
    cfg_replace_option opencmis.context.value "" $ALFRESCO_GLOBAL_PROPERTIES 
    cfg_replace_option opencmis.servletpath.override true $ALFRESCO_GLOBAL_PROPERTIES
    cfg_replace_option opencmis.servletpath.value "" $ALFRESCO_GLOBAL_PROPERTIES
    cfg_replace_option opencmis.server.override true $ALFRESCO_GLOBAL_PROPERTIES
    cfg_replace_option opencmis.server.value $REVERSE_PROXY_URL/alfresco/api $ALFRESCO_GLOBAL_PROPERTIES
    # Alfresco Office Service URL rewrite
    cfg_replace_option aos.baseUrlOverwrite $REVERSE_PROXY_URL/alfresco/aos $ALFRESCO_GLOBAL_PROPERTIES

    # Alfresco URL rewrite (i.e alfresco and share links found in emails)
    ALFRECO_HOSTNAME=`echo "$REVERSE_PROXY_URL" | awk '{split($0,a,"://"); print a[2]}'`
    ALFRECO_PROTOCOL=`echo "$REVERSE_PROXY_URL" | awk '{split($0,a,"://"); print a[1]}'`
    SHARE_HOSTNAME=`echo "$REVERSE_PROXY_URL" | awk '{split($0,a,"://"); print a[2]}'`
    SHARE_PROTOCOL=`echo "$REVERSE_PROXY_URL" | awk '{split($0,a,"://"); print a[1]}'`
    
    cfg_replace_option alfresco.host $ALFRESCO_HOSTNAME $ALFRESCO_GLOBAL_PROPERTIES
    cfg_replace_option alfresco.protocol $ALFRESCO_PROTOCOL $ALFRESCO_GLOBAL_PROPERTIES
    cfg_replace_option share.host $SHARE_HOSTNAME $ALFRESCO_GLOBAL_PROPERTIES
    cfg_replace_option share.protocol $SHARE_PROTOCOL $ALFRESCO_GLOBAL_PROPERTIES
  
  fi
}

tweak_alfresco
set_reverse_proxy

if [ -d "$AMP_DIR_ALFRESCO" ]; then
  echo "Installing Alfresco AMPs from $AMP_DIR_ALFRESCO..."
  $ALF_HOME/java/bin/java -jar $ALF_HOME/bin/alfresco-mmt.jar install $AMP_DIR_ALFRESCO $CATALINA_HOME/webapps/alfresco.war -directory -force -verbose
  $ALF_HOME/java/bin/java -jar $ALF_HOME/bin/alfresco-mmt.jar list $CATALINA_HOME/webapps/alfresco.war
fi

if [ -d "$AMP_DIR_SHARE" ]; then
  echo "Installing Share AMPs from $AMP_DIR_SHARE..."
  $ALF_HOME/java/bin/java -jar $ALF_HOME/bin/alfresco-mmt.jar install $AMP_DIR_SHARE $CATALINA_HOME/webapps/share.war -directory -force -verbose
  $ALF_HOME/java/bin/java -jar $ALF_HOME/bin/alfresco-mmt.jar list $CATALINA_HOME/webapps/share.war
fi

# start Tomcat
exec "$@"
