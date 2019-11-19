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
ENV MD_PREVIEW_VERSION='1.3.0'
ENV MANUAL_MANAGER_VERSION='1.0.0'

RUN set -x && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        dnsutils \
        netcat \
        xmlstarlet && \
    apt-get autoremove -y --purge && \
    apt-get clean && \
    rm -r /var/lib/apt/lists/*

# Download Alfresco Module Management
WORKDIR /root
RUN curl ${REPO}/org/alfresco/alfresco-mmt/${ALFRESCO_MMT_VERSION}/alfresco-mmt-${ALFRESCO_MMT_VERSION}.jar \
    -o alfresco-mmt.jar && \
    mkdir -p ./amp


# Deploy Alfresco Platform in Tomcat
WORKDIR ${CATALINA_HOME}
RUN curl ${REPO}/org/alfresco/share/${ALFRESCO_SHARE_VERSION}/share-${ALFRESCO_SHARE_VERSION}.war \
    -o share-${ALFRESCO_SHARE_VERSION}.war && \
    set -x && \
    unzip -q share-${ALFRESCO_SHARE_VERSION}.war -d webapps/share && \
    rm share-${ALFRESCO_SHARE_VERSION}.war


# Download Aikau plugin
WORKDIR ${CATALINA_HOME}/webapps/share/WEB-INF/lib
RUN curl ${REPO}/org/alfresco/aikau/${AIKAU_VERSION}/aikau-${AIKAU_VERSION}.jar \
    -o aikau-${AIKAU_VERSION}.jar

# Deploy Alfresco Google docs in Tomcat
WORKDIR /root/amp/
RUN curl ${REPO}/org/alfresco/integrations/alfresco-googledocs-share/${GOOGLE_DOCS_VERSION}/alfresco-googledocs-share-${GOOGLE_DOCS_VERSION}.amp \
    -o alfresco-googledocs-share-${GOOGLE_DOCS_VERSION}.amp

WORKDIR ${CATALINA_HOME}
RUN set -x && \
    java -jar /root/alfresco-mmt.jar install /root/amp/ webapps/share -nobackup -directory && \
    rm /root/amp/alfresco-googledocs-share-${GOOGLE_DOCS_VERSION}.amp

# Deploy Alfresco Manual Manager
WORKDIR ${CATALINA_HOME}/webapps/share/WEB-INF/lib/
RUN curl -L https://github.com/fjudith/manual-manager/releases/download/v${MANUAL_MANAGER_VERSION}/loftux-manual-manager.jar \
    -o loftux-manual-manager.jar

# Deploy Alfresco md-preview in Tomcat
WORKDIR /root/amp/
RUN curl -L https://github.com/fjudith/md-preview/releases/download/${MD_PREVIEW_VERSION}/parashift-mdpreview-share-${MD_PREVIEW_VERSION}.amp \
    -o parashift-mdpreview-share-${MD_PREVIEW_VERSION}.amp

WORKDIR ${CATALINA_HOME}
RUN set -x && \
    java -jar /root/alfresco-mmt.jar install /root/amp/ webapps/share -nobackup -directory && \
    rm /root/amp/parashift-mdpreview-share-${MD_PREVIEW_VERSION}.amp

# Create Directories
WORKDIR ${CATALINA_HOME}
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
WORKDIR ${CATALINA_HOME}

COPY assets/share-custom-config.xml shared/classes/alfresco/web-extension/share-config-custom.xml
COPY assets/index.jsp ${CATALINA_HOME}/webapps/ROOT/

RUN UUID=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1) && \
    xmlstarlet ed \
    -P -S -L \
    -i '/Server/Service[@name="Catalina"]/Connector[@port="8080"]' \
    -t 'attr' -n 'URIEncoding' -v 'UTF-8' \
    -i '/Server/Service[@name="Catalina"]/Connector[@port="8080"]' \
    -t 'attr' -n 'maxHttpHeaderSize' -v '32768' \
    -s '/Server/Service/Engine/Host[@name="localhost"]' -t 'elem' -n "${UUID}" \
    -i "/Server/Service/Engine/Host[@name='localhost']/${UUID}" \
    -t 'attr' -n 'className' -v 'org.apache.catalina.valves.RemoteIpValve' \
    -s "/Server/Service/Engine/Host[@name='localhost']/${UUID}" \
    -t 'attr' -n 'remoteIpHeader' -v 'x-forwarded-for' \
    -i "/Server/Service/Engine/Host[@name='localhost']/${UUID}" \
    -t 'attr' -n 'remoteIpProxiesHeader' -v 'x-forwarded-by' \
    -i "/Server/Service/Engine/Host[@name='localhost']/${UUID}" \
    -t 'attr' -n 'protocolHeader' -v 'x-forwarded-proto' \
    -r "/Server/Service/Engine/Host[@name='localhost']/${UUID}" \
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

WORKDIR ${CATALINA_HOME}
#WORKDIR /root

EXPOSE 8080 8443

COPY docker-entrypoint.sh /
RUN chmod +x /docker-entrypoint.sh

ENTRYPOINT [ "/docker-entrypoint.sh" ]
CMD ["catalina.sh", "run"]