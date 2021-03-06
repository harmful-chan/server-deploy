#!/bin/bash

source $D/../bin/base.sh
source $D/.env

preinstall_yum libxml2-devel openssl-devel libcurl-devel libjpeg-devel libpng-devel pcre-devel libxslt-devel bzip2-devel
preinstall_apt libxml2-dev libcurl4-openssl-dev libcurl-dev libjpeg-dev libpng-dev libpcre3-dev libxslt1-dev libbz2-dev


if istrue FREETYPE_BUILD; then
    cd `check freetype-2.4.10 freetype-2.4.10.tar.gz http://mirror.ossplanet.net/nongnu/freetype/freetype-old/freetype-2.4.10.tar.gz`
    ./configure --prefix=/usr/local/freetype
    $S rm -rf /usr/local/freetype
    make -j2 && $S make install
    cd -
fi


if istrue PHP_COMPILE_SRC; then
    cd `check tar.gz php-7.2.20 php-7.2.20.tar.gz https://www.php.net/distributions/php-7.2.20.tar.gz` 
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
    cd -
fi

if istrue PHP_INSTALL_SRC; then
    cd `check php-7.2.20 `
    $S rm -rf /usr/local/php
    $S make install
    cd -
fi


if istrue PHP_UPDATE_CONFIG; then

    cd `check $PHP_NAME`
    # 原 php.ini-development 
    # 修改 cgi.fix_pathinfo=0 允许文件不存在时nginx正常转发请求到 fpm
    $S cp -f php.ini-development /usr/local/php/lib/php.ini 
    $S sed -i 's/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/'  /usr/local/php/lib/php.ini 
    cd -

    # 添加 用户/组 www-data
    groups www-data ||  groupadd www-data
    id www-data || useradd -g www-data www-data
fi
