#! /bin/bash

pushd /alfresco/amps
wget https://github.com/fjudith/md-preview/releases/download/1.3.0/parashift-mdpreview-repo-1.3.0.amp
pushd /alfresco/amps_share
wget https://github.com/fjudith/md-preview/releases/download/1.3.0/parashift-mdpreview-share-1.3.0.amp
/alfresco/bin/apply_amps.sh
popd