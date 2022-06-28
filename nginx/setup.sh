#!/bin/bash

source $D/../bin/base.sh
source $D/.env


if istrue NGINX_UPDATE_SERVICE; then
    $S ln -sf $(pwd)/$D/nginx.service $SERVICE_DIR/nginx.service
fi

if istrue NGINX_COMPILE_SRC; then
    preinstall_yum ca-certificates pcre-devel openssl openssl-devel unzip
    preinstall_apt ca-certificates openssl unzip

    cd `check tar.gz nginx-1.20.2 nginx-1.20.2.tar.gz http://nginx.org/download/nginx-1.20.2.tar.gz`
    ./configure \
        --with-http_ssl_module \
        --with-stream \
        --with-stream_ssl_module
    make -j2 
    cd -
fi

if istrue NGINX_INSTALL_SRC; then
    isactive nginx && $S systemctl stop nginx
    $S rm -rf /usr/local/nginx
    $S make install
    cd -
fi

if istrue NGINX_UPDATE_CONFIG; then
    $S mkdir -p /usr/local/nginx/conf/nginx.conf.d

    rm -rf $D/conf/not_ssl.conf
    while read prot dns hostport localport; do   
        cat >>$D/conf/not_ssl.conf <<-EOF
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
    done <$D/tables.txt
    $S cp -rf $(pwd)/$D/conf/* /usr/local/nginx/conf/
fi


if istrue NGINX_UPDATE_CERT; then
    $S mkdir -p /usr/local/nginx/conf/cert
    $S cp -rf cert/sexhansc.com /usr/local/nginx/conf/cert/sexhansc.com
fi


