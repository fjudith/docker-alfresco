#!/bin/bash
# http://docs.alfresco.com/5.2/concepts/external-properties-solr6.html
# https://community.alfresco.com/docs/DOC-6556-using-solr-6-in-alfresco-community-edition-52-201612-ga

ALFRESCO_HOST=${ALFRESCO_HOST:-'repository'}
SOLR6_INSTALL_LOCATION=${SOLR6_INSTALL_LOCATION:-'/usr/share/alfresco-search-services'}
SOLR_SOLR_HOST=${SOLR_SOLR_HOST:-'localhost'}
SOLR_SOLR_PORT=${SOLR_SOLR_PORT:-'8983'}
SOLR_SOLR_BASEURL=${SOLR_SOLR_BASEURL:-'/solr'}
SOLR_SOLR_CONTENT_DIR=${SOLR_SOLR_CONTENT_DIR:-"${SOLR6_INSTALL_LOCATION}/contentstore"}
SOLR_SOLR_MODEL_DIR=${SOLR_SOLR_MODEL_DIR:-"${SOLR6_INSTALL_LOCATION}/solrhome/alfrescoModel"}
SOLR_HOME=${SOLR_HOME:-"${SOLR6_INSTALL_LOCATION}/solrhome"}
SOLR_JAVA_MEM=${SOLR_JAVA_MEM:-"-Xms1024m -Xmx1024m"}

mkdir -p ${SOLR_SOLR_SOLR_CONTENT_DIR} ${SOLR_SOLR_SOLR_MODEL_DIR}

function cfg_replace_option {
  grep -e "^$1" "$3" > /dev/null
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

cfg_replace_option SOLR_JAVA_MEM "\"${SOLR_JAVA_MEM}\"" /usr/share/alfresco-search-services/solr.in.sh
cfg_replace_option SOLR_SOLR_HOST "\"${SOLR_SOLR_HOST}\"" /usr/share/alfresco-search-services/solr.in.sh
cfg_replace_option SOLR_SOLR_PORT "\"${SOLR_SOLR_PORT}\"" /usr/share/alfresco-search-services/solr.in.sh
cfg_replace_option SOLR_SOLR_BASEURL "\"${SOLR_SOLR_BASEURL}\"" /usr/share/alfresco-search-services/solr.in.sh
cfg_replace_option SOLR_SOLR_CONTENT_DIR "\"${SOLR_SOLR_CONTENT_DIR}\"" /usr/share/alfresco-search-services/solr.in.sh
cfg_replace_option SOLR_SOLR_MODEL_DIR "\"${SOLR_SOLR_MODEL_DIR}\"" /usr/share/alfresco-search-services/solr.in.sh
cfg_replace_option SOLR_HOME "\"${SOLR_HOME}\"" /usr/share/alfresco-search-services/solr.in.sh

# trap SIGTERM and gracefully stops search service
trap '/usr/share/alfresco-search-services/solr/bin/solr stop;exit 0' SIGTERM
set -ex

# Create alfresco and archive cores 
if [ ! -f ${SOLR_HOME}/alfresco/core.properties ]; then   
    /usr/share/alfresco-search-services/solr/bin/solr start -force -a "-Dcreate.alfresco.defaults=alfresco,archive"
    sync
    sleep 20
    sync;
    /usr/share/alfresco-search-services/solr/bin/solr stop

    # Update "alfresco" core config files
    cfg_replace_option alfresco.host ${ALFRESCO_HOST} ${SOLR_HOME}/alfresco/conf/solrcore.properties
    cfg_replace_option data.dir.root ${SOLR_HOME} ${SOLR_HOME}/alfresco/conf/solrcore.properties

    # Update "archive" core config files
    cfg_replace_option alfresco.host ${ALFRESCO_HOST} ${SOLR_HOME}/archive/conf/solrcore.properties
    cfg_replace_option data.dir.root ${SOLR_HOME} ${SOLR_HOME}/archive/conf/solrcore.properties
fi

# starting the server
exec "$@"