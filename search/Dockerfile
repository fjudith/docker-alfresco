FROM amd64/openjdk:8-jdk-slim

LABEL maintainer='Florian JUDITH <florian.judith.b@gmail.com>'

# Default to UTF-8 file.encoding
ENV LANG=C.UTF-8

ENV DEBIAN_FRONTEND=noninteractive

ENV REPO="https://artifacts.alfresco.com/nexus/content/groups/public"
ENV ALFRESCO_SEARCH_SERVICE_VERSION=1.1.0


# Install dependencies
RUN set -x && \
    apt-get update -yqq && \
    apt-get install --no-install-recommends -yqq \
        dnsutils \
        netcat \
        supervisor \
        curl \
        procps \
        libgtk2.0-0 \
        libxtst6 \
        lsof \
        unzip && \
    apt-get autoremove -y --purge && \
    apt-get clean && \
    rm -r /var/lib/apt/lists/*

# Deploy Alfresco Platform in Tomcat
WORKDIR /usr/share
RUN set -x && \
    curl -L ${REPO}/org/alfresco/alfresco-search-services/${ALFRESCO_SEARCH_SERVICE_VERSION}/alfresco-search-services-${ALFRESCO_SEARCH_SERVICE_VERSION}.zip \
    -o alfresco-search-services-${ALFRESCO_SEARCH_SERVICE_VERSION}.zip && \
    unzip -q alfresco-search-services-${ALFRESCO_SEARCH_SERVICE_VERSION}.zip && \
    rm alfresco-search-services-${ALFRESCO_SEARCH_SERVICE_VERSION}.zip

COPY assets/supervisord.conf /etc/supervisord.conf

WORKDIR /usr/share/alfresco-search-services

COPY docker-entrypoint.sh /
RUN chmod +x /docker-entrypoint.sh

EXPOSE 8983 8443

ENTRYPOINT [ "/docker-entrypoint.sh" ]
CMD ["/usr/bin/supervisord","-c","/etc/supervisord.conf","-n"]
