#!/bin/bash

source $(dirname $BASH_SOURCE)/../base.sh


preinstall_yum ca-certificates pcre-devel openssl openssl-devel
preinstall_apt ca-certificates pcre-dev openssl openssl-dev

if istrue NGINX_UPDATE_SERVICE; then
    $S ln -sf $(pwd)/$(dirname $BASH_SOURCE)/nginx.service $SERVICE_DIR/nginx.service
fi

if istrue NGINX_INSTALL; then
    cd `check $NGINX_NAME $NGINX_NAME.tar.gz http://nginx.org/download/$NGINX_NAME.tar.gz` || exit $?
    ./configure \
        --with-http_ssl_module \
        --with-stream \
        --with-stream_ssl_module
    make -j2 

    isactive nginx || $S systemctl stop nginx
    $S rm -rf /usr/local/nginx
    $S make install
    cd -
fi

if istrue NGINX_UPDATE_CONFIG; then
    $S ln -sf $(pwd)/$(dirname $BASH_SOURCE)/nginx.conf /usr/local/nginx/conf/nginx.conf
fi


