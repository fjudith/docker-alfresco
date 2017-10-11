FROM amd64/openjdk:8-jdk-slim

LABEL maintainer="Florian JUDITH <florian.judith.b@gmail.com>"

# Default to UTF-8 file.encoding
ENV LANG=C.UTF-8

ENV DEBIAN_FRONTEND=noninteractive

ENV TERM=xterm
ENV CONNECTOR=mysql-connector-java-5.1.38
ENV ALF_HOME=/alfresco
ENV ALF_BUILD=201707-build-00028
ENV ALF_BIN=alfresco-community-installer-201707-linux-x64.bin

RUN set -x && \
    apt-get update -yqq && \
    apt-get install --no-install-recommends -yqq \
        bash \
        patch \
        libcups2 \
        libfontconfig1 \
        libdbus-glib-1-2 \
        hostname \
        libice6 \
        libsm6 \
        libxext6 \
        libxinerama1 \
        libxrender1 \
        supervisor \
        xmlstarlet \
        nano \
        imagemagick \
        ghostscript \
        wget curl


# Install Alfresco
ADD http://dl.alfresco.com/release/community/${ALF_BUILD}/${ALF_BIN} /tmp/
RUN mkdir -p ${ALF_HOME} && \
    cd /tmp && \
    chmod +x ${ALF_BIN} && \
    ./${ALF_BIN} --mode unattended --prefix ${ALF_HOME} --alfresco_admin_password admin && \
    rm ${ALF_BIN}

# Install MySQL connector for Alfresco
ADD http://dev.mysql.com/get/Downloads/Connector-J/${CONNECTOR}.tar.gz /tmp/
RUN cd /tmp && \
    tar xvzf ${CONNECTOR}.tar.gz ${CONNECTOR}/${CONNECTOR}-bin.jar && \
    mv ${CONNECTOR}/${CONNECTOR}-bin.jar ${ALF_HOME}/tomcat/lib && \
    rm -rf /tmp/${CONNECTOR}*

# this is for LDAP configuration
RUN mkdir -p /alfresco/tomcat/shared/classes/alfresco/extension/subsystems/Authentication/ldap/ldap1/
RUN mkdir -p /alfresco/tomcat/shared/classes/alfresco/extension/subsystems/Authentication/ldap-ad/ldap1/
COPY assets/ldap-authentication.properties /alfresco/tomcat/shared/classes/alfresco/extension/subsystems/Authentication/ldap/ldap1/ldap-authentication.properties
COPY assets/ldap-ad-authentication.properties /alfresco/tomcat/shared/classes/alfresco/extension/subsystems/Authentication/ldap-ad/ldap1/ldap-ad-authentication.properties

# Copy ManualManager Add-On
# Markdown manual editor and viewer
# https://github.com/loftuxab/manual-manager
#ADD build/dist/*.jar $ALF_HOME/tomcat/webapps/alfresco/WEB-INF/lib/
#ADD build/dist/*.jar $ALF_HOME/tomcat/webapps/alfresco/WEB-INF/lib/

# Copy Markdown Preview Add-On.
# https://github.com/cetra3/md-preview
ADD https://github.com/fjudith/md-preview/releases/download/1.3.0/parashift-mdpreview-share-1.3.0.amp /alfresco/amps_share/
ADD https://github.com/fjudith/md-preview/releases/download/1.3.0/parashift-mdpreview-repo-1.3.0.amp /alfresco/amps/


# install scripts
COPY docker-entrypoint.sh /alfresco/
RUN chmod +x /alfresco/docker-entrypoint.sh 
COPY assets/supervisord.conf /etc/

RUN mkdir -p /alfresco/tomcat/webapps/ROOT
COPY assets/index.jsp /alfresco/tomcat/webapps/ROOT/

VOLUME /alfresco/alf_data
VOLUME /alfresco/tomcat/logs

EXPOSE 21 137 138 139 445 8009 8080

ENTRYPOINT ["/alfresco/docker-entrypoint.sh"]
CMD ["/usr/bin/supervisord","-c","/etc/supervisord.conf","-n"]