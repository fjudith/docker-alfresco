#!/bin/bash
ALFRESCO_HOST=${ALFRESCO_HOST:-platform}

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

    xmlstarlet ed  \
        -P -S -L \
        -i '/alfresco-config/config[@condition="CSRFPolicy" and not(@replace)]' \
        -t 'attr' -n 'replace' -v 'true' \
        -s '/alfresco-config/config[@condition="CSRFPolicy"]/filter/rule/action[@name="assertOrigin"]' \
        -t 'elem' -n 'param' -v "$REVERSE_PROXY_URL" \
        -i '/alfresco-config/config[@condition="CSRFPolicy"]/filter/rule/action[@name="assertOrigin"]/param[not(@name)]' \
        -t 'attr' -n 'name' -v 'origin' \
        -s '/alfresco-config/config[@condition="CSRFPolicy"]/filter/rule/action[@name="assertReferer"]' \
        -t 'elem' -n 'param' -v "$REVERSE_PROXY_URL/.*" \
        -i '/alfresco-config/config[@condition="CSRFPolicy"]/filter/rule/action[@name="assertReferer"]/param[not(@name)]' \
        -t 'attr' -n 'name' -v 'referer' \
        $CATALINA_HOME/shared/classes/alfresco/web-extension/share-config-custom.xml
  
  fi

  echo ------------------------------
  echo CSRF rule configuration
  echo ------------------------------
  xmlstarlet sel -t -c '/alfresco-config/config[@condition="CSRFPolicy"]/filter/rule' $CATALINA_HOME/shared/classes/alfresco/web-extension/share-config-custom.xml
}

set_reverse_proxy

exec "$@"