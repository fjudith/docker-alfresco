Alfresco Share
===
[![](https://images.microbadger.com/badges/image/fjudith/alfresco-share.svg)](https://microbadger.com/images/fjudith/alfresco-share "Get your own image badge on microbadger.com")
[![Build Status](https://travis-ci.org/fjudith/docker-alfresco.svg?branch=master)](https://travis-ci.org/fjudith/docker-alfresco)

![high level architecture](https://raw.githubusercontent.com/fjudith/docker-alfresco/201707/alfresco_architecture.png)

# Supported tags and respective Dockerfile links

[`201707-share`, `share`](https://github.com/fjudith/docker-alfresco/tree/201707/share)

## Description

Alfresco is a leading and modular Enterprise Content Management system providing document management, collaboration, web content services and record management.

This image is aims to run the Web UI component **Alfresco Share** as decated container to consume the **Alfresco Content Repository**.

## Environment variables

| Name                | Description                                | Default  |
| ------------------- | ------------------------------------------ | -------- |
| `ALFRESCO_HOST`     | hostname of the alfresco platform instance | platform |
| `REVERSE_PROXY_URL` | url of the reverse-proxy                   | _empty_  |
