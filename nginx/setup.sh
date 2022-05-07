#!/bin/bash

source $(dirname $BASH_SOURCE)/../base.sh


preinstall ca-certificates pcre-devel openssl openssl-devel

e "NGINX_MAKE" "$NGINX_MAKE"
if [ "$NGINX_MAKE" == "true" ]; then
    if [ ! -e $TAR_DIR/$NGINX_NAME.tar.gz ]; then
        wget http://nginx.org/download/$NGINX_NAME.tar.gz -P $TAR_DIR
    fi
    if [ ! -d $TAR_DIR/$NGINX_NAME ]; then
        tar -xvf $TAR_DIR/$NGINX_NAME.tar.gz -C $TAR_DIR
    fi
    cd $TAR_DIR/$NGINX_NAME
    ./configure \
        --with-http_ssl_module \
        --with-stream \
        --with-stream_ssl_module
    make -j2 
    cd -
fi

e "NGINX_INSTALL" "$NGINX_INSTALL"
if [ "$NGINX_INSTALL" == "true" ]; then
    cd $TAR_DIR/$NGINX_NAME
    if [ "$(systemctl is-active nginx)" == "active" ]; then
        $S systemctl stop nginx
    fi
    $S rm -rf /usr/local/nginx
    $S make install
    cd -
fi

e "NGINX_UPDATE_CONFIG" "$NGINX_UPDATE_CONFIG"
if [ "$NGINX_UPDATE_CONFIG" == "true" ]; then
    $S ln -sf $(pwd)/$(dirname $BASH_SOURCE)/nginx.conf /usr/local/nginx/conf/nginx.conf
fi

e "NGINX_UPDATE_SERVICE" "$NGINX_UPDATE_SERVICE"
if [ "$NGINX_UPDATE_SERVICE" == "true" ]; then
    $S ln -sf $(pwd)/$(dirname $BASH_SOURCE)/nginx.service $SERVICE_DIR/nginx.service
fi
