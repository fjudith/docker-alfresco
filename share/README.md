Alfresco Share only
===

## Description

Alfresco is a leading Enterprise Content Management system which provides document management, collaboration, web content services and records and knowledge management.

This image is a micro-service running Alfresco Share running in `amd64/tomcat:7.0-jre8` designed to be linked to the Alfresco Platform Services `fjudith/alfresco:platform`.

## Environment variables

| Name                | Description                                | Default  |
| ------------------- | ------------------------------------------ | -------- |
| `ALFRESCO_HOST`     | hostname of the alfresco platform instance | platform |
| `REVERSE_PROXY_URL` | url of the reverse-proxy                   | _empty_  |


## Quikstart

```bash
docker run -it --rm -p 8080:8080 -p 8443:8443 --link platform:platform fjudith/alfrsco:platform
```