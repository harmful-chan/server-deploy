#!/bin/bash

source $D/../bin/base.sh
source $D/.env

if istrue PHPLDAPADMIN_INSTALL_BIN; then
    preinstall phpldapadmin
fi

if istrue PHPLDAPADMIN_UPDATE_CONFIG; then
    # 修改 
    # $servers->setValue('login','anon_bind',false);    不允许匿名访问
    # $servers->setValue('login','allowed_dns',array('cn=Manager,dc=hans,dc=org'));     只允许管理员登录
    # $servers->setValue('server','base',array('dc=hans,dc=org'));    设置根记录
    $S cp /usr/share/phpldapadmin/config/config.php.example /etc/phpldapadmin/config.php
    echo -e '$-0i\n$servers->setValue('"'login'"','"'anon_bind'"',false);\n.\nw\n' | $S ex -s /etc/phpldapadmin/config.php
    echo -e '$-0i\n$servers->setValue('"'login'"','"'allowed_dns'"',array('"'cn=Manager,dc=hans,dc=org'"'));\n.\nw\n' | $S ex -s /etc/phpldapadmin/config.php
    echo -e '$-0i\n$servers->setValue('"'server'"','"'base'"',array('"'dc=hans,dc=org'"'));\n.\nw\n' | $S ex -s /etc/phpldapadmin/config.php

    $S mkdir -p /usr/local/php/etc/phpldapadmin/conf
    $S cp $D/conf/fpm.conf $D/conf/www.conf /usr/local/php/etc/phpldapadmin/conf/
    $S cp $D/conf/nginx-phpldapadmin.conf /usr/local/nginx/conf/nginx.conf.d/


fi

if istrue PHPLDAPADMIN_UPDATE_SERVICE; then
    $S ln -sf $(pwd)/$D/phpldapadmin.service $SERVICE_DIR/phpldapadmin.service
fi