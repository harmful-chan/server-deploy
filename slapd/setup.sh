#!/bin/bash

source $(dirname $BASH_SOURCE)/../bin/base.sh
source $(dirname $BASH_SOURCE)/.env

if istrue LDAP_UPDATE_SERVICE; then
    $S ln -sf $(pwd)/$(dirname $BASH_SOURCE)/slapd.service $SERVICE_DIR/slapd.service
fi

if istrue OPENSSL_BUILD; then

    cd `check openssl-1.1.1 openssl-1.1.1.tar.gz https://www.openssl.org/source/openssl-1.1.1.tar.gz` || exit $?
    ./config --prefix=/usr/local/openssl
    make -j2 
    $S rm -rf /usr/local/openssl
    $S make install
    $S mv /usr/bin/openssl /usr/bin/openssl.bak    
    $S ln -sf /usr/local/openssl/bin/openssl /usr/bin/openssl
    # 重新加载动态库
    if [ "$(tail -n1 /etc/ld.so.conf)" != "/usr/local/openssl/lib" ]; then
        echo "/usr/local/openssl/lib" >>  /etc/ld.so.conf 
    fi
    $S ldconfig -v
    cd -
fi

if istrue LDAP_INSTALL; then

    cd `check git $LDAP_NAME https://git.openldap.org/openldap/$LDAP_NAME.git  --depth 1` || exit $?

    if ist LDAP_CONF_OPENSS; then
        ./configure --prefix=/usr/local/openldap CPPFLAGS="-I/usr/local/openssl/include"  LDFLAGS="-L/usr/local/openssl/lib"
    else
        ./configure --prefix=/usr/local/openldap
    fi
    make depend
    make -j2 

    isactive slapd ||  $S systemctl stop slapd

    $S rm -rf /usr/local/openldap
    $S make install
    $S mkdir -p /etc/openldap/slapd.d
    $S mkdir -p /var/lib/openldap/data
    cd -
fi

if istrue LDAP_UPDATE_CONFIG; then
    # 初始化配置文件。slapd.ldif 修改了，管理员账户号：Manager,dc=hans,dc=org，密码：123456
    $S rm -rf /etc/openldap/slapd.d/*
    $S slapadd -n 0 -F /etc/openldap/slapd.d -l $(dirname $BASH_SOURCE)/conf/slapd.ldif    
fi

if istrue LDAP_LOAD_DEMO; then
    isactive slapd ||  $S systemctl start slapd
    # 创建两条记录
    # 根 hans.org
    # 管理员 Manager.hans.org
    $S ldapadd -x -D "cn=Manager,dc=hans,dc=org" -w 123456 -f $(dirname $BASH_SOURCE)/conf/entry.ldif 
    # 导入员工信息
    $S ldapadd -x -D "cn=Manager,dc=hans,dc=org" -w 123456 -f $(dirname $BASH_SOURCE)/conf/group.ldif 
    $S ldapadd -x -D "cn=Manager,dc=hans,dc=org" -w 123456 -f $(dirname $BASH_SOURCE)/conf/people.ldif 

    $S systemctl stop slapd
fi
