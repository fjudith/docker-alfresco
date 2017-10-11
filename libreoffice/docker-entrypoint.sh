#!/bin/bash

set -ex

PATH=$LIBREOFFICE_PATH/program:$PATH

if [ "$1" == "run" ]; then
	exec soffice --nofirststartwizard --nologo --headless --norestore --invisible  --accept="socket,host=${HOST},port=${PORT},tcpNoDelay=1;urp;StarOffice.ServiceManager"
else
	exec "$@"
fi