#!/bin/bash
ALFRESCO_HOST=${ALFRESCO_HOST:-repository}

xmlstarlet ed  \
    -P -S -L \
    -u '/alfresco-config/config[@evaluator="string-compare"]/remote/endpoint[id="alfresco-noauth"]/endpoint-url' \
    -v "http://${ALFRESCO_HOST}:8080/alfresco/s" \
    -u '/alfresco-config/config[@evaluator="string-compare"]/remote/endpoint[id="alfresco"]/endpoint-url' \
    -v "http://${ALFRESCO_HOST}:8080/alfresco/s" \
    -u '/alfresco-config/config[@evaluator="string-compare"]/remote/endpoint[id="alfresco-feed"]/endpoint-url' \
    -v "http://${ALFRESCO_HOST}:8080/alfresco/s" \
    -u '/alfresco-config/config[@evaluator="string-compare"]/remote/endpoint[id="alfresco-api"]/endpoint-url' \
    -v "http://${ALFRESCO_HOST}:8080/alfresco/api" \
    $CATALINA_HOME/shared/classes/alfresco/web-extension/share-config-custom.xml

echo ------------------------------
echo Share endpoint configuration
echo ------------------------------
xmlstarlet sel -t -c '/alfresco-config/config[@evaluator="string-compare"]/remote' $CATALINA_HOME/shared/classes/alfresco/web-extension/share-config-custom.xml

function set_reverse_proxy {
  if [ -z $REVERSE_PROXY_URL ]; then
    echo "INFO: Reverse proxy not configured"
  else
    echo "INFO: Configuring alfresco for independant reverse-proxy support"
    
    SHARE_SECURITY_CONFIG="${CATALINA_HOME}/webapps/share/WEB-INF/classes/alfresco/share-security-config.xml"
    SHARE_SECURITY_TEMP="${CATALINA_HOME}/webapps/share/WEB-INF/classes/alfresco/share-security-config.xml.tmp"
    SHARE_CONFIG_CUSTOM="${CATALINA_HOME}/shared/classes/alfresco/web-extension/share-config-custom.xml"
    
    # Write CSRF node in temp file
    xmlstarlet sel -E utf-8 -t -c '/alfresco-config/config[@condition="CSRFPolicy" and not(@replace)]' ${SHARE_SECURITY_CONFIG} > ${SHARE_SECURITY_TEMP}
     
    # Insert rever-proxy config in temp file
    xmlstarlet ed  \
        -L \
        -i '/config[@condition="CSRFPolicy" and not(@replace)]' \
        -t 'attr' -n 'replace' -v 'true' \
        -s '/config[@condition="CSRFPolicy"]/filter/rule/action[@name="assertOrigin"]' \
        -t 'elem' -n 'param' -v "$REVERSE_PROXY_URL" \
        -i '/config[@condition="CSRFPolicy"]/filter/rule/action[@name="assertOrigin"]/param[not(@name)]' \
        -t 'attr' -n 'name' -v 'origin' \
        -s '/config[@condition="CSRFPolicy"]/filter/rule/action[@name="assertReferer"]' \
        -t 'elem' -n 'param' -v "$REVERSE_PROXY_URL/.*" \
        -i '/config[@condition="CSRFPolicy"]/filter/rule/action[@name="assertReferer"]/param[not(@name)]' \
        -t 'attr' -n 'name' -v 'referer' \
        ${SHARE_SECURITY_TEMP}

    # Backup Restore share-config-custom.xml to prevent doubled insertion
    if ! [ -f ${SHARE_CONFIG_CUSTOM}.backup ]; then
      cp ${SHARE_CONFIG_CUSTOM} ${SHARE_CONFIG_CUSTOM}.backup
    else
      cp ${SHARE_CONFIG_CUSTOM}.backup ${SHARE_CONFIG_CUSTOM}
    fi

    # Remove closing root node
    sed -i 's/<\/alfresco\-config>//g' ${SHARE_CONFIG_CUSTOM}
    # Insert CSRF config in share-config-custom.xml
    xmlstarlet sel -E utf-8 -t -c '/config[@condition="CSRFPolicy" and (@replace)="true"]' ${SHARE_SECURITY_TEMP} >> ${SHARE_CONFIG_CUSTOM}
    # Restore closing root node
    echo '</alfresco-config>' >> ${SHARE_CONFIG_CUSTOM}

    # Remove temp file
    rm -f ${SHARE_SECURITY_TEMP}
  fi

  echo ------------------------------
  echo CSRF rule configuration
  echo ------------------------------
  xmlstarlet sel -t -c '/alfresco-config/config[@condition="CSRFPolicy"]/filter/rule' $CATALINA_HOME/shared/classes/alfresco/web-extension/share-config-custom.xml
}

set_reverse_proxy

exec "$@"