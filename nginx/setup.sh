#!/bin/bash

source $(dirname $BASH_SOURCE)/../bin/base.sh
source $(dirname $BASH_SOURCE)/.env

preinstall_yum ca-certificates pcre-devel openssl openssl-devel unzip
preinstall_apt ca-certificates openssl unzip

if istrue NGINX_UPDATE_SERVICE; then
    $S ln -sf $(pwd)/$(dirname $BASH_SOURCE)/nginx.service $SERVICE_DIR/nginx.service
fi

if istrue NGINX_INSTALL_SRC; then
    cd `check tar.gz $NGINX_NAME $NGINX_NAME.tar.gz http://nginx.org/download/$NGINX_NAME.tar.gz` || exit $?
    ./configure \
        --with-http_ssl_module \
        --with-stream \
        --with-stream_ssl_module
    make -j2 

    isactive nginx || $S systemctl stop nginx
    $S rm -rf /usr/local/nginx
    $S make install
    $S mkdir -p /usr/local/nginx/conf/nginx.conf.d
    cd -
fi

if istrue NGINX_UPDATE_CONFIG; then
    $S mkdir -p /usr/local/nginx/conf/nginx.conf.d

    rm -rf $(dirname $BASH_SOURCE)/conf/not_ssl.conf
    while read prot dns hostport localport; do   
        cat >>$(dirname $BASH_SOURCE)/conf/not_ssl.conf <<-EOF
server {
    listen              $hostport ssl;
    server_name         $dns;
    ssl_certificate     cert/sexhansc.com/sexhansc.com.crt;
    ssl_certificate_key cert/sexhansc.com/sexhansc.com.key;
    ssl_protocols       TLSv1 TLSv1.1 TLSv1.2;
    ssl_ciphers         HIGH:!aNULL:!MD5;

    location / {
        proxy_pass http://127.0.0.1:$localport;     
        proxy_set_header Host            \$host;
        proxy_set_header X-Real-IP       \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    }
}
EOF
    done <$(dirname $BASH_SOURCE)/tables.txt
    $S cp -rf $(pwd)/$(dirname $BASH_SOURCE)/conf/* /usr/local/nginx/conf/
fi


if istrue NGINX_UPDATE_CERT; then
    $S mkdir -p /usr/local/nginx/conf/cert
    $S cp -rf cert/sexhansc.com /usr/local/nginx/conf/cert/sexhansc.com
fi


