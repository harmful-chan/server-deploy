#!/bin/bash

source $(dirname $BASH_SOURCE)/../base.sh

preinstall_yum libxml2-devel openssl-devel libcurl-devel libjpeg-devel libpng-devel pcre-devel libxslt-devel bzip2-devel
preinstall_apt libxml2-dev libcurl4-openssl-dev curl-dev libjpeg-dev libpng-dev libpcre3-dev libxslt1-dev libbbz2-dev

if istrue PHP_INSTALL; then
    cd `check $PHP_NAME $PHP_NAME.tar.gz https://www.php.net/distributions/$PHP_NAME.tar.gz` || exit $?
    ./configure --prefix=/usr/local/php --with-freetype=/usr/local/freetype/  \
        --with-curl --with-gd --with-gettext --with-iconv-dir \
        --with-kerberos --with-libdir=lib64 --with-libxml-dir --with-mysqli --with-openssl \
        --with-pcre-regex --with-pdo-mysql --with-pdo-sqlite --with-pear --with-png-dir \
        --with-jpeg-dir --with-xmlrpc --with-xsl --with-zlib --with-bz2 --with-mhash \
        --enable-fpm --enable-bcmath --enable-libxml --enable-inline-optimization --enable-mbregex \
        --enable-mbstring --enable-opcache --enable-pcntl --enable-shmop --enable-soap \
        --enable-sockets --enable-sysvsem --enable-sysvshm --enable-xml --enable-zip
    make -j2 

    isactive php ||  $S systemctl stop nginx
    $S make install
    cd -
fi

if istrue PHP_INSTALL; then
    cd $TAR_DIR/$PHP_NAME
    isactive php ||  $S systemctl stop nginx

    $S rm -rf /usr/local/nginx
    $S make install
    cd -
fi

if istrue PHP_UPDATE_CONFIG; then
    $S ln -sf $(pwd)/$(dirname $BASH_SOURCE)/nginx.conf /usr/local/nginx/conf/nginx.conf
fi

if istrue PHP_UPDATE_SERVICE; then
    $S ln -sf $(pwd)/$(dirname $BASH_SOURCE)/nginx.service $SERVICE_DIR/nginx.service
fi
