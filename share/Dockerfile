FROM amd64/tomcat:7.0-jre8

LABEL maintainer='Florian JUDITH <florian.judith.b@gmail.com>'

# Default to UTF-8 file.encoding
ENV LANG=C.UTF-8

ENV DEBIAN_FRONTEND=noninteractive

ENV JAVA_OPTS " -XX:-DisableExplicitGC -Djava.security.egd=file:/dev/./urandom -Djava.awt.headless=true -Dfile.encoding=UTF-8 "

ENV REPO="https://artifacts.alfresco.com/nexus/content/groups/public"
ENV ALFRESCO_MMT_VERSION='5.2.g'
ENV ALFRESCO_SHARE_VERSION='5.2.f'
ENV REPO_SHARE_EXTRA="https://artifacts.alfresco.com/nexus/service/local/repositories/share-extras/content"
ENV ALFRESCO_OAUTH_VERSION='2.3.0'
ENV AIKAU_VERSION='1.0.102'
ENV GOOGLE_DOCS_VERSION='3.0.4.2'

RUN set -x && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        xmlstarlet


# Download Alfresco Module Management
WORKDIR /root
RUN curl ${REPO}/org/alfresco/alfresco-mmt/${ALFRESCO_MMT_VERSION}/alfresco-mmt-${ALFRESCO_MMT_VERSION}.jar \
    -o alfresco-mmt.jar && \
    mkdir -p ./amp


# Deploy Alfresco Platform in Tomcat
WORKDIR /usr/local/tomcat
RUN curl ${REPO}/org/alfresco/share/${ALFRESCO_SHARE_VERSION}/share-${ALFRESCO_SHARE_VERSION}.war \
    -o share-${ALFRESCO_SHARE_VERSION}.war && \
    set -x && \
    unzip -q share-${ALFRESCO_SHARE_VERSION}.war -d webapps/share && \
    rm share-${ALFRESCO_SHARE_VERSION}.war


# Download Share OAUTH plugin
WORKDIR /webapps/share/WEB-INF/lib
RUN curl ${REPO_SHARE_EXTRA}/org/sharextras/share-oauth/${ALFRESCO_OAUTH_VERSION}/share-oauth-${ALFRESCO_OAUTH_VERSION}.jar \
    -o share-oauth-${ALFRESCO_OAUTH_VERSION}.jar


# Download Aikau plugin
WORKDIR /webapps/share/WEB-INF/lib
RUN curl ${REPO}/org/alfresco/aikau/${AIKAU_VERSION}/aikau-${AIKAU_VERSION}.jar \
    -o aikau-${AIKAU_VERSION}.jar

# Deploy Alfresco Google docs in Tomcat
WORKDIR /root/amp/
RUN curl ${REPO}/org/alfresco/integrations/alfresco-googledocs-share/${GOOGLE_DOCS_VERSION}/alfresco-googledocs-share-${GOOGLE_DOCS_VERSION}.amp \
    -o alfresco-googledocs-share-${GOOGLE_DOCS_VERSION}.amp

WORKDIR /usr/local/tomcat
RUN set -x && \
    java -jar /root/alfresco-mmt.jar install /root/amp/ webapps/share -nobackup -directory && \
    rm /root/amp/alfresco-googledocs-share-${GOOGLE_DOCS_VERSION}.amp


# Create Directories
WORKDIR /usr/local/tomcat
RUN set -x && \
    sed -i 's/^log4j.rootLogger.*/log4j.rootLogger=error, Console/' webapps/share/WEB-INF/classes/log4j.properties && \
    mkdir -p  shared/classes/alfresco/extension \
              shared/lib && \
    rm -rf /usr/share/doc \
           webapps/docs \
           webapps/examples \
           webapps/manager \
           webapps/host-manager


# Tuning
WORKDIR /usr/local/tomcat

COPY assets/share-custom-config.xml shared/classes/alfresco/web-extension/share-config-custom.xml
COPY assets/index.jsp /usr/local/tomcat/webapps/ROOT/

RUN xmlstarlet ed \
    -P -S -L \
    -i '/Server/Service[@name="Catalina"]/Connector[@port="8080"]' \
    -t 'attr' -n 'URIEncoding' -v 'UTF-8' \
    -i '/Server/Service[@name="Catalina"]/Connector[@port="8080"]' \
    -t 'attr' -n 'maxHttpHeaderSize' -v '32768' \
    -s '/Server/Service/Engine/Host[@name="localhost"]' -t 'elem' -n 'abc' \
    -i '/Server/Service/Engine/Host[@name="localhost"]/abc' \
    -t 'attr' -n 'className' -v 'org.apache.catalina.valves.RemoteIpValve' \
    -s '/Server/Service/Engine/Host[@name="localhost"]/abc' \
    -t 'attr' -n 'remoteIpHeader' -v 'x-forwarded-for' \
    -i '/Server/Service/Engine/Host[@name="localhost"]/abc' \
    -t 'attr' -n 'remoteIpProxiesHeader' -v 'x-forwarded-by' \
    -i '/Server/Service/Engine/Host[@name="localhost"]/abc' \
    -t 'attr' -n 'protocolHeader' -v 'x-forwarded-proto' \
    -r '/Server/Service/Engine/Host[@name="localhost"]/abc' \
    -v 'Valve' \
    conf/server.xml && cat conf/server.xml

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
    sed -i 's#^\(4catalina.org.apache.juli.FileHandler.prefix = \).*$#\1host-manager.#g' conf/logging.properties && \
    sed -i 's#^\(org.apache.catalina.core.ContainerBase.\[Catalina\].\[localhost\].handlers = \).*$#\12localhost.org.apache.juli.FileHandler, java.util.logging.ConsoleHandler#g' conf/logging.properties && \
    sed -i 's#^\(org.apache.catalina.core.ContainerBase.\[Catalina\].\[localhost\].\[/manager\].handlers = \).*$#\13manager.org.apache.juli.FileHandler, java.util.logging.ConsoleHandler#g' conf/logging.properties && \
    sed -i 's#^\(org.apache.catalina.core.ContainerBase.\[Catalina\].\[localhost\].\[/host-manager\].handlers = \).*$#\14host-manager.org.apache.juli.FileHandler, java.util.logging.ConsoleHandler#g' conf/logging.properties


# Cleanup
RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /usr/local/tomcat
#WORKDIR /root

EXPOSE 8080 8443

COPY docker-entrypoint.sh /
RUN chmod +x /docker-entrypoint.sh

ENTRYPOINT [ "/docker-entrypoint.sh" ]
CMD ["catalina.sh", "run"]