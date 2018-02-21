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
ENV MD_PREVIEW_VERSION=1.3.0
ENV MANUAL_MANAGER_VERSION=1.0.0

RUN set -x && \
    apt-get update -yqq && \
    apt-get install --no-install-recommends -yqq \
        dnsutils \
        procps \
        bash \
        patch \
        libcairo2 \
        libglu1-mesa \
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
WORKDIR /tmp
RUN curl -L http://dl.alfresco.com/release/community/${ALF_BUILD}/${ALF_BIN} \
    -o ${ALF_BIN}

RUN mkdir -p ${ALF_HOME} && \
    sync && \
    chmod +x ${ALF_BIN} && \
    sync && \
    ./${ALF_BIN} --mode unattended --prefix ${ALF_HOME} --alfresco_admin_password admin && \
    rm ${ALF_BIN}

# Install MySQL connector for Alfresco
WORKDIR /tmp
RUN curl -L http://dev.mysql.com/get/Downloads/Connector-J/${CONNECTOR}.tar.gz \
    -o ${CONNECTOR}.tar.gz

RUN tar xvzf ${CONNECTOR}.tar.gz ${CONNECTOR}/${CONNECTOR}-bin.jar && \
    mv ${CONNECTOR}/${CONNECTOR}-bin.jar ${ALF_HOME}/tomcat/lib && \
    rm -rf /tmp/${CONNECTOR}*

# this is for LDAP configuration
WORKDIR /alfresco/tomcat/shared/classes/alfresco/extension/subsystems/Authentication
RUN mkdir -p ldap/ldap1/
RUN mkdir -p ldap-ad/ldap1/
COPY assets/ldap-authentication.properties ldap/ldap1/ldap-authentication.properties
COPY assets/ldap-ad-authentication.properties ldap-ad/ldap1/ldap-ad-authentication.properties

# Copy ManualManager Add-On
# Markdown manual editor and viewer
# https://github.com/loftuxab/manual-manager
WORKDIR /alfresco/tomcat/webapps/alfresco/WEB-INF/lib/
RUN curl -L https://github.com/fjudith/manual-manager/releases/download/v${MANUAL_MANAGER_VERSION}/loftux-manual-manager.jar \
    -o loftux-manual-manager.jar

WORKDIR /alfresco/tomcat/webapps/share/WEB-INF/lib/
RUN curl -L https://github.com/fjudith/manual-manager/releases/download/v${MANUAL_MANAGER_VERSION}/loftux-manual-manager.jar \
    -o loftux-manual-manager.jar

# Copy Markdown Preview Add-On.
# https://github.com/cetra3/md-preview
WORKDIR /alfresco/amps_share
RUN curl -L https://github.com/fjudith/md-preview/releases/download/${MD_PREVIEW_VERSION}/parashift-mdpreview-share-${MD_PREVIEW_VERSION}.amp \
    -o parashift-mdpreview-share-${MD_PREVIEW_VERSION}.amp

WORKDIR /alfresco/amps/
RUN curl -L https://github.com/fjudith/md-preview/releases/download/${MD_PREVIEW_VERSION}/parashift-mdpreview-repo-${MD_PREVIEW_VERSION}.amp \
    -o parashift-mdpreview-repo-${MD_PREVIEW_VERSION}.amp

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