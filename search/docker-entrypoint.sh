#!/bin/bash

ALFRESCO_HOST=${ALFRESCO_HOST:-repository}
JAVA_OPTS_XMS=${JAVA_OPTS_XMS:-512}
JAVA_OPTS_XMX=${JAVA_OPTS_XMX:-512}


# trap SIGTERM and gracefully stops search service
trap '/usr/share/alfresco-search-services/solr/bin/solr stop;exit 0' SIGTERM
set -ex

#  Dry run for directory generation
if [ ! -d /usr/share/alfresco-search-services/solrhome/alfresco ]; then
   /usr/share/alfresco-search-services/solr/bin/solr start -force -a "-Dcreate.alfresco.defaults=alfresco,archive"
   sync
   sleep 20
   sync;
   /usr/share/alfresco-search-services/solr/bin/solr stop

# Set alfresco target host
   sed -i "s#\(alfresco.host=\).*#\1${ALFRESCO_HOST}#g" /usr/share/alfresco-search-services/solrhome/archive/conf/solrcore.properties
   sed -i "s#\(alfresco.host=\).*#\1=${ALFRESCO_HOST}#g" /usr/share/alfresco-search-services/solrhome/alfresco/conf/solrcore.properties
fi

# Tune memory
if grep -q ^SOLR_JAVA_MEM= /usr/share/alfresco-search-services/solr.in.sh ; then
    sed -i "s/-Xms[^ ]* /-Xms"$JAVA_OPTS_XMS"m /g" /usr/share/alfresco-search-services/solr.in.sh
    sed -i "s/-Xmx[^ ]* /-Xmx"$JAVA_OPTS_XMX"m /g" /usr/share/alfresco-search-services/solr.in.sh
        
else
    echo  "SOLR_JAVA_MEM=\"-Xms"$JAVA_OPTS_XMS"m -Xmx"$JAVA_OPTS_XMX"m\"" >> "/usr/share/alfresco-search-services/solr.in.sh"
fi

# starting the server
exec "$@"