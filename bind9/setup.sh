#!/bin/bash

source $(dirname $BASH_SOURCE)/../bin/base.sh
source $(dirname $BASH_SOURCE)/.env

if istrue BIND9_INSTALL_SRC; then

    preinstall_apt pkg-config python3-pip libuv1 libuv1-dev libssl-dev libcap-dev libxml2-dev
    cd `check git bind9 https://github.com/isc-projects/bind9.git  -b v9_16_9 --depth=1` || exit $?
    ./configure --prefix=/usr/local/bind9 \
        --sysconfdir=/etc/bind9 \
        --localstatedir=/var \
        --with-openssl \
        --with-libxml2
    make -j2 

    isactive bind9 ||  $S systemctl stop bind9

    $S rm -rf /usr/local/bind9
    $S make install
    cd -
fi

if istrue BIND9_UPDATE_CONFIG; then
    groups named || $S  groupadd  -r  -g  53  named
    id named || $S useradd  -r  -u  53   -g  53  named
    
    $S mkdir -p /var/named/private/ 
    $S cp -arf $(dirname $BASH_SOURCE)/named/* /var/named/

    $S mkdir -p /etc/bind9/named.conf.d
    $S cp -arf $(dirname $BASH_SOURCE)/conf/* /etc/bind9/

    $S mkdir -p /var/named/data
    $S mkdir -p /var/log/bind9 
    $S mkdir -p /var/run/bind9
    # rndc.key
    $S /usr/local/bind9/sbin/rndc-confgen -a

    # 默认用named用户启动，配置为640，named:named 权限
    $S chown -R named.named /usr/local/bind9/ /etc/bind9/ /var/named/ /var/log/bind9/ /var/run/bind9/  
    #$S chmod -R 755 /etc/bind9 /var/named

    # 检查配置
    /usr/local/bind9/sbin/named-checkzone  sexhansc.com  /var/named/private/sexhansc.com.zone
    /usr/local/bind9/sbin/named-checkzone  1.168.192.in-addr.arpa  /var/named/private/1.168.192.zone
    /usr/local/bind9/sbin/named-checkzone  0.168.192.in-addr.arpa  /var/named/private/0.168.192.zone
fi

if istrue BIND9_UPDATE_SERVICE; then
    $S cp -f $(pwd)/$(dirname $BASH_SOURCE)/bind9.service $SERVICE_DIR/bind9.service
fi