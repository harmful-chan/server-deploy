#!/bin/bash

source $(dirname $BASH_SOURCE)/../base.sh

preinstall_yum libxml2-devel openssl-devel libcurl-devel libjpeg-devel libpng-devel pcre-devel libxslt-devel bzip2-devel
preinstall_apt libxml2-dev libcurl4-openssl-dev curl-dev libjpeg-dev libpng-dev libpcre3-dev libxslt1-dev libbbz2-dev


if istrue FREETYPE_BUILD; then
    cd `check freetype-2.4.10 freetype-2.4.10.tar.gz http://mirror.ossplanet.net/nongnu/freetype/freetype-old/freetype-2.4.10.tar.gz` || exit $?
    ./configure --prefix=/usr/local/freetype
    $S rm -rf /usr/local/freetype
    make -j2 && $S make install
    cd -
fi


if istrue PHP_INSTALL; then
    cd `check $PHP_NAME $PHP_NAME.tar.gz https://www.php.net/distributions/$PHP_NAME.tar.gz` || exit $?
    if ist PHP_CONF_LDAP; then
        $S ln -sf  /usr/local/openldap/lib /usr/local/openldap/lib64
    fi
    
    ./configure --prefix=/usr/local/php \
        --with-freetype$(ist PHP_CONF_FREETYPE && echo =/usr/local/freetype || echo -dir )  \
        $(ist PHP_CONF_LDAP && echo --with-ldap=/usr/local/openldap)  \
        --with-curl --with-gd --with-gettext --with-iconv-dir \
        --with-kerberos --with-libdir=lib64 --with-libxml-dir --with-mysqli --with-openssl \
        --with-pcre-regex --with-pdo-mysql --with-pdo-sqlite --with-pear --with-png-dir \
        --with-jpeg-dir --with-xmlrpc --with-xsl --with-zlib --with-bz2 --with-mhash \
        --enable-fpm --enable-bcmath --enable-libxml --enable-inline-optimization --enable-mbregex \
        --enable-mbstring --enable-opcache --enable-pcntl --enable-shmop --enable-soap \
        --enable-sockets --enable-sysvsem --enable-sysvshm --enable-xml --enable-zip
    make -j2 
    $S rm -rf /usr/local/php
    $S make install
    $S cp sapi/fpm/php-fpm /usr/local/bin    
    cd -
fi


if istrue PHP_FPM_UPDATE_CONFIG; then
    # 原 php.ini-development 
    # 修改 cgi.fix_pathinfo=0 允许文件不存在时nginx正常转发请求到 fpm
    $S cp -f $(pwd)/$(dirname $BASH_SOURCE)/php.ini /usr/local/php/lib/php.ini 
    # 原 /usr/local/php/etc/php-fpm.conf.default 
    # 修改 pid = /var/run/php-fpm.pid
    $S cp -f $(pwd)/$(dirname $BASH_SOURCE)/php-fpm.conf /usr/local/php/etc/php-fpm.conf
    # 原 /usr/local/php/etc/php-fpm.d/www.conf.default
    # 修改 user = www-data，group = www-data
    $S cp -f $(pwd)/$(dirname $BASH_SOURCE)/www.conf /usr/local/php/etc/php-fpm.d/www.conf

    # 添加 用户/组 www-data
    groups www-data 
    if [ $? -ne 0 ]; then
        groupadd www-data
    fi
    id www-data 
    if [ $? -ne 0 ]; then
        useradd -g www-data www-data
    fi


fi

if istrue PHP_FPM_UPDATE_SERVICE; then
    $S ln -sf $(pwd)/$(dirname $BASH_SOURCE)/php-fpm.service $SERVICE_DIR/php-fpm.service
fi
