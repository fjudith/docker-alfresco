FROM amd64/openjdk:7-jdk-slim

LABEL maintainer='Florian JUDITH <florian.judith.b@gmail.com'

# Default to UTF-8 file.encoding
ENV LANG=C.UTF-8

ENV DEBIAN_FRONTEND=noninteractive

ENV REPO=http://download.documentfoundation.org/libreoffice/stable/
ENV LIBREOFFICE_VERSION=6.3
ENV LIBREOFFICE_PATCH_VERSION=6.3.3
ENV LIBREOFFICE_RELEASE_VERSION=${LIBREOFFICE_PATCH_VERSION}.2
ENV LIBREOFFICE_PATH="/opt/libreoffice${LIBREOFFICE_VERSION}"

# Create user
RUN useradd -ms /bin/bash libreoffice


# Install dependencies
RUN apt-get update -yqq && \
    apt-get install -yqq --no-install-recommends \
        dnsutils \
        netcat \
        curl \
        fontconfig \
        libglu1-mesa \
        libsm6 \
        libice6 \
        libxrender1 \
        libxext6 \
        libcups2 \
        libcairo2 \
        libxinerama1 \
        libdbus-glib-1-2 \
        ghostscript\
        libfreetype6 \
        imagemagick \
        xfonts-100dpi \
        xfonts-75dpi \
        gsfonts-x11 \
        fonts-freefont-otf \
        fonts-freefont-ttf \
        fonts-liberation \
        ttf-liberation && \
    apt-get autoremove -y --purge && \
    apt-get clean && \
    rm -r /var/lib/apt/lists/*

# Download & install Libreoffice
WORKDIR /tmp
RUN set -x && \
    curl --silent --location \
        ${REPO}/${LIBREOFFICE_PATCH_VERSION}/deb/x86_64/LibreOffice_${LIBREOFFICE_PATCH_VERSION}_Linux_x86-64_deb.tar.gz | tar xvz && \
    dpkg -R --install LibreOffice_${LIBREOFFICE_RELEASE_VERSION}_Linux_x86-64_deb/DEBS/ && \
    chown -R libreoffice:libreoffice ${LIBREOFFICE_PATH} && \
    ln -s ${LIBREOFFICE_PATH} /opt/libreoffice && \
    rm -rf /tmp/LibreOffice_${LIBREOFFICE_RELEASE_VERSION}_Linux_x86-64_deb

COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

WORKDIR ${LIBREOFFICE_PATH}

ENV HOST='0.0.0.0'
ENV PORT='8100'

EXPOSE 8100

USER libreoffice

ENTRYPOINT [ "/docker-entrypoint.sh" ]
CMD ["run"]
