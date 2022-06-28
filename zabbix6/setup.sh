#!/bin/bash

source $D/../bin/base.sh
source $D/.env


if istrue GO_INSTALL_PKG; then
    
    echo `check tar.gz go1.18.3.linux-amd64 go1.18.3.linux-amd64.tar.gz https://go.dev/dl/go1.18.3.linux-amd64.tar.gz`
    $S rm -rf /usr/local/go
    $S cp -r `check go` /usr/local/go
    $S ln -s /usr/local/go/bin/go /usr/bin/go
    $S ln -s /usr/local/go/bin/gofmt /usr/bin/gofmt
    # 设置模块下载源
    $S go env -w GO111MODULE=on
    $S go env -w GOPROXY=https://goproxy.cn,direct
fi

if istrue NETSNMP_INSTALL_SRC; then    # 不能用 
    
    preinstall_apt libperl-dev 
    cd `check git net-snmp https://github.com/net-snmp/net-snmp.git -b v5.9.1 --depth=1`
    # --with-ldflags="-lsensors" \
    # --with-mib-modules="ucd-snmp/lmsensorsMib ucd-snmp/diskio ip-mib/ipv4InterfaceTable" \
    # lmsensorsMib表示使用lm-sensors模块监控硬件的工作情况
    # diskio表示服务器支持监视磁盘的io情况
    # --with-default-snmp-version  #表示设置net-snmp使用哪个版本
    # --with-sys-contact  #表示设备联系信息
    # --with-sys-location #表示设备地理位置
    # --with-logfile  #表示日志文件存放位置
    # --with-persistent-directory  #表示数据存放地址
    ./configure --prefix=/usr/local/snmp \
        --enable-embedded-perl --enable-shared \
        --with-default-snmp-version="2" \
        --with-sys-contact="mason" \
        --with-sys-location="GuangZhou" \
        --with-logfile="/var/log/snmp/snmpd.log" \
        --with-persistent-directory="/var/lib/snmp/data" \
    
    $S mkdir -p /var/{log/snmp,lib/snmp/data}
    $S touch /var/log/snmp/snmpd.log
    make -j2 

    $S rm -rf /usr/local/snmp
    $S mkdir -p /usr/local/snmp
    $S make install
    cd -
fi

if istrue ZABBIX6_COMPILE_SRC; then
    preinstall_apt libcurl4-openssl-dev libxml2-dev libopenipmi-dev snmp libevent-dev
    preinstall_yum libcurl-devel libxml2-devel libopenipmi-devel snmp libevent-devel
    cd `check tar.gz zabbix-6.0.5 zabbix-6.0.5.tar.gz https://cdn.zabbix.com/zabbix/sources/stable/6.0/zabbix-6.0.5.tar.gz` || exit $?
    ./configure --prefix=/usr/local/zabbix6 \
        --enable-server \
        --enable-agent2 \
        --enable-ipv6 \
        --with-openssl=/usr/local/openssl \
        --with-mysql$(ist ZABBIX6_CONF_MYSQL && echo =/usr/local/mysql8/bin/mysql_config) \
        --with-net-snmp$(ist ZABBIX6_CONF_SNMP && echo =/usr/local/snmp/bin/net-snmp-config)  \
        --with-libcurl \
        --with-libxml2 \
        --with-openipmi
    
    make  -j2
    cd -
fi

if istrue ZABBIX6_INSTALL_SRC; then
    cd `check zabbix-6.0.5`
    isactive zabbix-server &&  $S systemctl stop zabbix-server
    isactive zabbix-agent2 &&  $S systemctl stop zabbix-agent2
    $S rm -rf /usr/local/zabbix6
    $S make install
    cd -
fi


if istrue ZABBIX6_INSTALL_WEB; then
    cd `check zabbix-6.0.5`
    $S rm -rf /usr/local/zabbix6/ui
    $S cp -r ui /usr/local/zabbix6/ui
    $S chown -R www-data:www-data /usr/local/zabbix6/ui
    cd -
fi

if istrue ZABBIX6_INIT_MYSQL8; then
    isactive mysql8 ||  $S systemctl start mysql8

    /usr/local/mysql8/bin/mysql  -uroot -h127.0.01 -p123456 <<-EOF
create database zabbix character set utf8mb4 collate utf8mb4_bin;
create user zabbix@localhost identified by 'zabbix';
grant all privileges on zabbix.* to zabbix@localhost;
EOF
fi

if istrue ZABBIX6_INIT_DATABASE; then
    isactive mysql8 ||  $S systemctl start mysql8

    cd `check zabbix-6.0.5`
    /usr/local/mysql8/bin/mysql -uzabbix -pzabbix  zabbix < database/mysql/schema.sql
    /usr/local/mysql8/bin/mysql -uzabbix -pzabbix  zabbix < database/mysql/images.sql 
    /usr/local/mysql8/bin/mysql -uzabbix -pzabbix  zabbix < database/mysql/data.sql
    cd -
fi



if istrue ZABBIX6_UPDATE_CONFIG; then
    groups zabbix  || groupadd -r zabbix
    id zabbix || useradd -r -g zabbix -d /var/lib/zabbix6 -s /sbin/nologin zabbix
    
    $S mkdir -p /var/lib/zabbix6    # home 目录
    $S mkdir -p /var/log/zabbix6    # 日志

    $S touch /var/log/zabbix6/zabbix_server.log
    $S touch /var/log/zabbix6/php-fpm.log
   
    
    $S chown zabbix:zabbix /var/log/zabbix6/zabbix_server.log

    $S cp -f $D/conf/{php-fpm.conf,zabbix.conf,zabbix_server.conf} /usr/local/zabbix6/etc/
    $S cp -f $D/conf/zabbix6-nginx.conf /usr/local/nginx/conf/nginx.conf.d/
fi



if istrue ZABBIX6_UPDATE_SERVICE; then
    $S cp -f $(pwd)/$D/zabbix6-server.service $SERVICE_DIR/zabbix6-server.service
    $S cp -f $(pwd)/$D/zabbix6-agent2.service $SERVICE_DIR/zabbix6-agent2.service
fi

