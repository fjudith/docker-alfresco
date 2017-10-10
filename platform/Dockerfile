FROM amd64/tomcat:7.0-jre8

LABEL maintainer='Florian JUDITH <florian.judith.b@gmail.com>'

# Default to UTF-8 file.encoding
ENV LANG=C.UTF-8

ENV DEBIAN_FRONTEND=noninteractive

ENV JAVA_OPTS " -XX:-DisableExplicitGC -Djava.security.egd=file:/dev/./urandom -Djava.awt.headless=true -Dfile.encoding=UTF-8 "

ENV REPO="https://artifacts.alfresco.com/nexus/content/groups/public"
ENV MD_PREVIEW="https://github.com/fjudith/md-preview"
ENV ALFRESCO_MMT_VERSION='5.2.g'
ENV ALFRESCO_PLATFORM_VERSION='5.2.g'
ENV ALFRESCO_SHARE_SERVICES_VERSION='5.2.f'
ENV POSTGRES_CONNECTOR_VERSION='9.2-1002.jdbc4'
ENV MYSQL_CONNECTOR_VERSION='5.1.38'
ENV MD_PREVIEW_VERSION='1.3.0'

RUN set -x && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        imagemagick \
        ghostscript \
        xmlstarlet

# Download Alfresco Module Management
WORKDIR /root
ADD ${REPO}/org/alfresco/alfresco-mmt/${ALFRESCO_MMT_VERSION}/alfresco-mmt-${ALFRESCO_MMT_VERSION}.jar \
    alfresco-mmt.jar
RUN mkdir -p ./amp


# Deploy Alfresco Platform in Tomcat
WORKDIR /usr/local/tomcat
ADD ${REPO}/org/alfresco/alfresco-platform/${ALFRESCO_PLATFORM_VERSION}/alfresco-platform-${ALFRESCO_PLATFORM_VERSION}.war \
    alfresco-platform-${ALFRESCO_PLATFORM_VERSION}.war
RUN set -x && \
    unzip -q alfresco-platform-${ALFRESCO_PLATFORM_VERSION}.war -d webapps/alfresco && \
    rm alfresco-platform-${ALFRESCO_PLATFORM_VERSION}.war


# Deploy Alfresco Share Services in Tomcat
WORKDIR /usr/local/tomcat
ADD ${REPO}/org/alfresco/alfresco-share-services/${ALFRESCO_SHARE_SERVICES_VERSION}/alfresco-share-services-${ALFRESCO_SHARE_SERVICES_VERSION}.amp \
    /root/amp/alfresco-share-services-${ALFRESCO_SHARE_SERVICES_VERSION}.amp
RUN set -x && \
    java -jar /root/alfresco-mmt.jar install /root/amp/ webapps/alfresco -nobackup -directory && \
    rm /root/amp/alfresco-share-services-${ALFRESCO_SHARE_SERVICES_VERSION}.amp


# Add PostgreSQL driver to Tomcat
WORKDIR /usr/local/tomcat/lib
ADD ${REPO}/postgresql/postgresql/${POSTGRES_CONNECTOR_VERSION}/postgresql-${POSTGRES_CONNECTOR_VERSION}.jar \
    lib/postgresql-${POSTGRES_CONNECTOR_VERSION}.jar


# Add MySQL driver to Tomcat
WORKDIR /usr/local/tomcat/lib
ADD http://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-${MYSQL_CONNECTOR_VERSION}.tar.gz \
    mysql-connector-java-${MYSQL_CONNECTOR_VERSION}.tar.gz
RUN set -x \
    tar xvzf mysql-connector-java-${MYSQL_CONNECTOR_VERSION}.tar.gz \
             --strip-components 1 \
             mysql-connector-java-${MYSQL_CONNECTOR_VERSION}/mysql-connector-java-${MYSQL_CONNECTOR_VERSION}-bin.jar && \
    rm mysql-connector-java-${MYSQL_CONNECTOR_VERSION}.tar.gz

# Create Directories
WORKDIR /usr/local/tomcat
RUN set -x && \
    sed -i 's/^log4j.rootLogger.*/log4j.rootLogger=error, Console/' webapps/alfresco/WEB-INF/classes/log4j.properties && \
    mkdir -p  shared/classes/alfresco/extension \
              shared/classes/alfresco/messages \
              shared/lib \
              /var/lib/alf_data && \
    rm -rf /usr/share/doc \
           webapps/docs \
           webapps/examples \
           webapps/manager \
           webapps/host-manager


# Tuning
WORKDIR /usr/local/tomcat
RUN xmlstarlet ed \
    -P -S -L \
    -i '/Server/Service[@name="Catalina"]/Connector[@port="8080"]' -t 'attr' -n 'URIEncoding' -v 'UTF-8' \
    -i '/Server/Service[@name="Catalina"]/Connector[@port="8080"]' -t 'attr' -n 'maxHttpHeaderSize' -v '32768' \
    conf/server.xml
RUN sed -i 's#^\(shared.loader=\).*$#\1${catalina.base}/shared/classes,${catalina.base}/shared/lib/*.jar#g' conf/catalina.properties
RUN sed -i 's#^\(handlers = \).*$#\11catalina.org.apache.juli.FileHandler, 2localhost.org.apache.juli.FileHandler, 3manager.org.apache.juli.FileHandler, 4host-manager.org.apache.juli.FileHandler, java.util.logging.ConsoleHandler#g' conf/logging.properties && \
    sed -i 's#^\(.handlers = \).*$#\11catalina.org.apache.juli.FileHandler, java.util.logging.ConsoleHandler#g' conf/logging.properties && \
    sed -i 's#^\(1catalina.org.apache.juli.FileHandler.level = \).*$#\1FINE#g' conf/logging.properties && \
    sed -i 's#^\(1catalina.org.apache.juli.FileHandler.directory = \).*$#\1${catalina.base}/logs#g' conf/logging.properties && \
    sed -i 's#^\(1catalina.org.apache.juli.FileHandler.prefix = \).*$#\1catalina.#g' conf/logging.properties && \
    sed -i 's#^\(2catalina.org.apache.juli.FileHandler.level = \).*$#\1FINE#g' conf/logging.properties && \
    sed -i 's#^\(2catalina.org.apache.juli.FileHandler.directory = \).*$#\1${catalina.base}/logs#g' conf/logging.properties && \
    sed -i 's#^\(2catalina.org.apache.juli.FileHandler.prefix = \).*$#\1localhost.#g' conf/logging.properties && \
    sed -i 's#^\(3catalina.org.apache.juli.FileHandler.level = \).*$#\1FINE#g' conf/logging.properties && \
    sed -i 's#^\(3catalina.org.apache.juli.FileHandler.directory = \).*$#\1${catalina.base}/logs#g' conf/logging.properties && \
    sed -i 's#^\(3catalina.org.apache.juli.FileHandler.prefix = \).*$#\1manager.#g' conf/logging.properties && \
    sed -i 's#^\(4catalina.org.apache.juli.FileHandler.level = \).*$#\1FINE#g' conf/logging.properties && \
    sed -i 's#^\(4catalina.org.apache.juli.FileHandler.directory = \).*$#\1${catalina.base}/logs#g' conf/logging.properties && \
    sed -i 's#^\(4catalina.org.apache.juli.FileHandler.prefix = \).*$#\1host-manager.#g' conf/logging.properties
RUN sed -i 's#^\(org.apache.catalina.core.ContainerBase.\[Catalina\].\[localhost\].handlers = \).*$#\12localhost.org.apache.juli.FileHandler, java.util.logging.ConsoleHandler#g' conf/logging.properties && \
    sed -i 's#^\(org.apache.catalina.core.ContainerBase.\[Catalina\].\[localhost\].\[/manager\].handlers = \).*$#\13manager.org.apache.juli.FileHandler, java.util.logging.ConsoleHandler#g' conf/logging.properties && \
    sed -i 's#^\(org.apache.catalina.core.ContainerBase.\[Catalina\].\[localhost\].\[/host-manager\].handlers = \).*$#\14host-manager.org.apache.juli.FileHandler, java.util.logging.ConsoleHandler#g' conf/logging.properties

# Cleanup
RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/*
#COPY assets/catalina.properties conf/catalina.properties
#COPY assets/server.xml conf/server.xml
#COPY assets/logging.properties conf/logging.properties
#COPY assets/web.xml webapps/alfresco/WEB-INF/web.xml
#COPY assets/alfresco-global.properties webapps/alfresco/WEB-INF/classes/alfresco-global.properties

WORKDIR /usr/local/tomcat
#WORKDIR /root

VOLUME "/opt/alf_data/"

COPY docker-entrypoint.sh /
RUN chmod +x /docker-entrypoint.sh

ENTRYPOINT [ "/docker-entrypoint.sh" ]
CMD ["catalina.sh", "run"]