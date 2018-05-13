# Rook File System Storage Class


## Overview

The following example enables Alfresco to use the [Rook File System Dynamic Provisioning](https://github.com/rook/rook/blob/master/design/dynamic-provision-filesystem.md) to persist datas by leveraging the [Storage Class](https://kubernetes.io/docs/concepts/storage/storage-classes) and [Persistent Volume Claim (PVC)](https://kubernetes.io/docs/concepts/storage/persistent-volumes/#persistentvolumeclaims) feature of Kubernetes.


> A healthy Rook Cluster is required prior to the installation of the Rook File System Dynamic Provisioning components.

## Installation

```bash
kubectl apply -f https://raw.githubusercontent.com/fjudith/docker-alfresco/master/kubernetes/storage/rook-filesystem/rook-storageclass.yaml
kubectl apply -f https://raw.githubusercontent.com/fjudith/docker-alfresco/master/kubernetes/storage/rook-filesystem/alfresco-rook-persistentvolumeclaim.yaml
```