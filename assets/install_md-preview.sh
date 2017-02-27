#! /bin/bash

pushd /alfresco/amps
wget https://github.com/fjudith/md-preview/releases/download/1.2.1/parashift-mdpreview-repo-1.2.1.amp
pushd /alfresco/amps_share
wget https://github.com/fjudith/md-preview/releases/download/1.2.1/parashift-mdpreview-share-1.2.1.amp
/alfresco/bin/apply_amps.sh
popd