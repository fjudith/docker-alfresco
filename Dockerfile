FROM centos:centos7

MAINTAINER Florian JUDITH <florian.judith.b@gmail.com>

ENV TERM=xterm
ENV JAVA_RPM=jdk-8u131-linux-x64.rpm
ENV CONNECTOR=mysql-connector-java-5.1.38
ENV JAVA_URL=http://download.oracle.com/otn-pub/java/jdk/8u131-b11/d54c1d3a095b4ff2b6607d096fa80163/$JAVA_RPM
ENV ALF_HOME=/alfresco
ENV ALF_BUILD=201707-build-00028
ENV ALF_BIN=alfresco-community-installer-201707-linux-x64.bin

# install some necessary/desired RPMs and get updates
RUN yum update -y && \
    yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm && \
    yum install -y \
        git \
        ant \
        cups-libs \
        dbus-glib \
        fontconfig \
        hostname \
        libICE \
        libSM \
        libXext \
        libXinerama \
        libXrender \
        supervisor \
        xmlstarlet \
        nano \
        ImageMagick \
        ghostscript \
        wget \
        unzip && \
    yum clean all

# Install Oracle Java JDK
RUN wget --no-cookies --no-check-certificate --header "Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com%2F; oraclelicense=accept-securebackup-cookie" $JAVA_URL && \
    yum localinstall -y ./$JAVA_RPM && \
    update-alternatives --install /usr/bin/java java /usr/java/latest/bin/java 1065 && \
    update-alternatives --install /usr/bin/javac javac /usr/java/latest/bin/javac 1065 && \
    update-alternatives --install /usr/bin/jar jar /usr/java/latest/bin/jar 1065 && \
    update-alternatives --install /usr/bin/javaws javaws /usr/java/latest/bin/javaws 1065 && \
    rm $JAVA_RPM

# Install Alfresco
RUN mkdir -p $ALF_HOME && \
    cd /tmp && \
    curl -O http://dl.alfresco.com/release/community/$ALF_BUILD/$ALF_BIN && \
    chmod +x $ALF_BIN && \
    ./$ALF_BIN --mode unattended --prefix $ALF_HOME --alfresco_admin_password admin && \
    rm $ALF_BIN

# Install MySQL connector for Alfresco
RUN cd /tmp && \
    curl -OL http://dev.mysql.com/get/Downloads/Connector-J/${CONNECTOR}.tar.gz && \
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
COPY add-ons/install_manualmanager.sh /tmp/
RUN chmod +x /tmp/install_manualmanager.sh

# Copy BeCPG Add-On.
# http://www.becpg.fr/
COPY add-ons/install_becpg.sh /tmp/
RUN chmod +x /tmp/install_becpg.sh

# Copy Markdown Preview Add-On.
# https://github.com/cetra3/md-preview
COPY add-ons/install_md-preview.sh /tmp/
RUN chmod +x /tmp/install_md-preview.sh

# install scripts
COPY docker-entrypoint.sh /alfresco/
RUN chmod +x /alfresco/docker-entrypoint.sh 
COPY assts/supervisord.conf /etc/

RUN mkdir -p /alfresco/tomcat/webapps/ROOT
COPY assets/index.jsp /alfresco/tomcat/webapps/ROOT/

VOLUME /alfresco/alf_data
VOLUME /alfresco/tomcat/logs

EXPOSE 21 137 138 139 445 8009 8080

ENTRYPOINT ["/alfresco/docker-entrypoint.sh"]
CMD ["/usr/bin/supervisord","-c","/etc/supervisord.conf","-n"]