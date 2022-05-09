#!/bin/bash

source $(dirname $BASH_SOURCE)/../base.sh


preinstall_yum ca-certificates pcre-devel openssl openssl-devel
preinstall_apt ca-certificates pcre-dev openssl openssl-dev

if istrue NGINX_MAKE; then
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

if istrue NGINX_INSTALL; then
    cd $TAR_DIR/$NGINX_NAME
    if [ "$(systemctl is-active nginx)" == "active" ]; then
        $S systemctl stop nginx
    fi
    $S rm -rf /usr/local/nginx
    $S make install
    cd -
fi

if istrue NGINX_UPDATE_CONFIG; then
    $S ln -sf $(pwd)/$(dirname $BASH_SOURCE)/nginx.conf /usr/local/nginx/conf/nginx.conf
fi

if istrue NGINX_UPDATE_SERVICE; then
    $S ln -sf $(pwd)/$(dirname $BASH_SOURCE)/nginx.service $SERVICE_DIR/nginx.service
fi
