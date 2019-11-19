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
ENV ALFRESCO_PDF_RENDERER_VERSION='1.0'
ENV REPO_SHARE_EXTRA="https://artifacts.alfresco.com/nexus/service/local/repositories/share-extras/content"
ENV POSTGRES_CONNECTOR_VERSION='9.2-1002.jdbc4'
ENV MYSQL_CONNECTOR_VERSION='5.1.38'
ENV AOS_MODULE_VERSION='1.1.6'
ENV AIKAU_VERSION='1.0.102'
ENV GOOGLE_DOCS_VERSION='3.0.4.2'
ENV MD_PREVIEW_VERSION='1.3.0'
ENV MANUAL_MANAGER_VERSION='1.0.0'

RUN set -x && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        dnsutils \
        netcat \
        imagemagick \
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
RUN curl ${REPO}/org/alfresco/alfresco-platform/${ALFRESCO_PLATFORM_VERSION}/alfresco-platform-${ALFRESCO_PLATFORM_VERSION}.war \
    -o alfresco-platform-${ALFRESCO_PLATFORM_VERSION}.war && \
    set -x && \
    unzip -q alfresco-platform-${ALFRESCO_PLATFORM_VERSION}.war -d webapps/alfresco && \
    rm alfresco-platform-${ALFRESCO_PLATFORM_VERSION}.war


# Download Aikau plugin
WORKDIR ${CATALINA_HOME}/webapps/alfresco/WEB-INF/lib
RUN curl ${REPO}/org/alfresco/aikau/${AIKAU_VERSION}/aikau-${AIKAU_VERSION}.jar \
    -o aikau-${AIKAU_VERSION}.jar


# Deploy Alfresco Share Services in Tomcat
WORKDIR /root/amp/
RUN curl ${REPO}/org/alfresco/alfresco-share-services/${ALFRESCO_SHARE_SERVICES_VERSION}/alfresco-share-services-${ALFRESCO_SHARE_SERVICES_VERSION}.amp \
    -o alfresco-share-services-${ALFRESCO_SHARE_SERVICES_VERSION}.amp

WORKDIR ${CATALINA_HOME}
RUN set -x && \
    java -jar /root/alfresco-mmt.jar install /root/amp/ webapps/alfresco -nobackup -directory && \
    rm /root/amp/alfresco-share-services-${ALFRESCO_SHARE_SERVICES_VERSION}.amp


# Deploy Alfresco Office Services in Tomcat
WORKDIR /root/amp/
RUN curl ${REPO}/org/alfresco/aos-module/alfresco-aos-module/${AOS_MODULE_VERSION}/alfresco-aos-module-${AOS_MODULE_VERSION}.amp \
    -o alfresco-aos-module-${AOS_MODULE_VERSION}.amp

WORKDIR ${CATALINA_HOME}
RUN set -x && \
    java -jar /root/alfresco-mmt.jar install /root/amp/ webapps/alfresco -nobackup -directory && \
    rm /root/amp/alfresco-aos-module-${AOS_MODULE_VERSION}.amp


# Deploy Alfresco Google docs in Tomcat
WORKDIR /root/amp/
RUN curl ${REPO}/org/alfresco/integrations/alfresco-googledocs-repo/${GOOGLE_DOCS_VERSION}/alfresco-googledocs-repo-${GOOGLE_DOCS_VERSION}.amp \
    -o alfresco-googledocs-repo-${GOOGLE_DOCS_VERSION}.amp

WORKDIR ${CATALINA_HOME}
RUN set -x && \
    java -jar /root/alfresco-mmt.jar install /root/amp/ webapps/alfresco -nobackup -directory && \
    rm /root/amp/alfresco-googledocs-repo-${GOOGLE_DOCS_VERSION}.amp

 # Deploy Alfresco Manual Manager in Tomcat
WORKDIR ${CATALINA_HOME}/webapps/alfresco/WEB-INF/lib/
RUN curl -L https://github.com/fjudith/manual-manager/releases/download/v${MANUAL_MANAGER_VERSION}/loftux-manual-manager.jar \
    -o loftux-manual-manager.jar

# Deploy Alfresco md-preview in Tomcat
WORKDIR /root/amp/
RUN curl -L https://github.com/fjudith/md-preview/releases/download/${MD_PREVIEW_VERSION}/parashift-mdpreview-repo-${MD_PREVIEW_VERSION}.amp \
    -o parashift-mdpreview-repo-${MD_PREVIEW_VERSION}.amp

WORKDIR ${CATALINA_HOME}
RUN set -x && \
    java -jar /root/alfresco-mmt.jar install /root/amp/ webapps/alfresco/ -nobackup -verbose -directory && \
    rm /root/amp/parashift-mdpreview-repo-${MD_PREVIEW_VERSION}.amp


# Add PostgreSQL driver to Tomcat
WORKDIR ${CATALINA_HOME}/lib
RUN curl ${REPO}/postgresql/postgresql/${POSTGRES_CONNECTOR_VERSION}/postgresql-${POSTGRES_CONNECTOR_VERSION}.jar \
    -o postgresql-${POSTGRES_CONNECTOR_VERSION}.jar


# Add MySQL driver to Tomcat
WORKDIR ${CATALINA_HOME}/lib
RUN curl http://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-${MYSQL_CONNECTOR_VERSION}.tar.gz \
    -o mysql-connector-java-${MYSQL_CONNECTOR_VERSION}.tar.gz
RUN set -x \
    tar xvzf mysql-connector-java-${MYSQL_CONNECTOR_VERSION}.tar.gz \
             --strip-components 1 \
             mysql-connector-java-${MYSQL_CONNECTOR_VERSION}/mysql-connector-java-${MYSQL_CONNECTOR_VERSION}-bin.jar && \
    rm mysql-connector-java-${MYSQL_CONNECTOR_VERSION}.tar.gz

# Deploy Alfresco PDF Render
WORKDIR /usr/local/bin
RUN curl ${REPO}/org/alfresco/alfresco-pdf-renderer/${ALFRESCO_PDF_RENDERER_VERSION}/alfresco-pdf-renderer-${ALFRESCO_PDF_RENDERER_VERSION}-linux.tgz \
    -o alfresco-pdf-renderer-${ALFRESCO_PDF_RENDERER_VERSION}-linux.tgz
RUN set -x \
    tar xvzf alfresco-pdf-renderer-${ALFRESCO_PDF_RENDERER_VERSION}-linux.tgz && \
    tar xvzf alfresco-pdf-renderer-${ALFRESCO_PDF_RENDERER_VERSION}-linux.tgz && \
    ls -l && \
    chmod +x alfresco-pdf-renderer && \
    rm alfresco-pdf-renderer-${ALFRESCO_PDF_RENDERER_VERSION}-linux.tgz


# Create Directories
WORKDIR ${CATALINA_HOME}
RUN set -x && \
    sed -i 's/^log4j.rootLogger.*/log4j.rootLogger=error, Console/' webapps/alfresco/WEB-INF/classes/log4j.properties && \
    mkdir -p  shared/classes/alfresco/extension \
              shared/classes/alfresco/messages \
              shared/lib \
              /var/lib/alfresco/alf_data && \
    rm -rf /usr/share/doc \
           webapps/docs \
           webapps/examples \
           webapps/manager \
           webapps/host-manager


# this is for LDAP configuration
WORKDIR ${CATALINA_HOME}
RUN mkdir -p shared/classes/alfresco/extension/subsystems/Authentication/ldap/ldap1/
RUN mkdir -p shared/classes/alfresco/extension/subsystems/Authentication/ldap-ad/ldap1/
COPY assets/ldap-authentication.properties shared/classes/alfresco/extension/subsystems/Authentication/ldap/ldap1/ldap-authentication.properties
COPY assets/ldap-ad-authentication.properties shared/classes/alfresco/extension/subsystems/Authentication/ldap-ad/ldap1/ldap-ad-authentication.properties


# Tuning
WORKDIR ${CATALINA_HOME}
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
    sed -i 's#^\(4catalina.org.apache.juli.FileHandler.prefix = \).*$#\1host-manager.#g' conf/logging.properties && \
    sed -i 's#^\(org.apache.catalina.core.ContainerBase.\[Catalina\].\[localhost\].handlers = \).*$#\12localhost.org.apache.juli.FileHandler, java.util.logging.ConsoleHandler#g' conf/logging.properties && \
    sed -i 's#^\(org.apache.catalina.core.ContainerBase.\[Catalina\].\[localhost\].\[/manager\].handlers = \).*$#\13manager.org.apache.juli.FileHandler, java.util.logging.ConsoleHandler#g' conf/logging.properties && \
    sed -i 's#^\(org.apache.catalina.core.ContainerBase.\[Catalina\].\[localhost\].\[/host-manager\].handlers = \).*$#\14host-manager.org.apache.juli.FileHandler, java.util.logging.ConsoleHandler#g' conf/logging.properties

WORKDIR ${CATALINA_HOME}

VOLUME "/var/lib/alfresco/alf_data"

COPY docker-entrypoint.sh /
RUN chmod +x /docker-entrypoint.sh

ENTRYPOINT [ "/docker-entrypoint.sh" ]
CMD ["catalina.sh", "run"]