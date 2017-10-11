FROM amd64/openjdk:7-jdk-slim

LABEL maintainer='Florian JUDITH <florian.judith.b@gmail.com'

# Default to UTF-8 file.encoding
ENV LANG=C.UTF-8

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update -yq && \
    aptget install -yq --no-install-recommends